 /**********************************************************************
  * MPINU				                               *
  * Copyright (c) 2004-2005 Gene Cooperman <gene@ccs.neu.edu>          *
  *                                                                    *
  * This library is free software; you can redistribute it and/or      *
  * modify it under the terms of the GNU Lesser General Public         *
  * License as published by the Free Software Foundation; either       *
  * version 2.1 of the License, or (at your option) any later version. *
  *                                                                    *
  * This library is distributed in the hope that it will be useful,    *
  * but WITHOUT ANY WARRANTY; without even the implied warranty of     *
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU   *
  * Lesser General Public License for more details.                    *
  *                                                                    *
  * You should have received a copy of the GNU Lesser General Public   *
  * License along with this library (see file COPYING); if not, write  *
  * to the Free Software Foundation, Inc., 59 Temple Place, Suite      *
  * 330, Boston, MA 02111-1307 USA, or contact Gene Cooperman          *
  * <gene@ccs.neu.edu>.                                                *
  **********************************************************************/

#include "mpi.h"
#include "mpiimpl.h"

/* index into MPINU_pg_array is same as process rank in MPI_Comm_world */
struct pg_struct MPINU_pg_array[PG_ARRAY_SIZE];

int MPINU_myrank = 0;
int MPINU_num_slaves;
static int ssh_slaves; /* num orig slaves, not counting MPI_Spawn2() */
int MPINU_coll_comm_flag = 0;
int MPINU_my_list_sd;
fd_set MPINU_fdset;
int MPINU_max_sd;
int MPINU_is_spawn2 = 0; /* Set inside mpi_spawn2 before unexec, then reset */
		/* Used by slave.c to determine if slave from mpi_spawn2 */
int MPINU_is_initialized = 0;
static void sigpipe_handler(int dummy){ }

int MPI_Init(argc_ptr, argv_ptr)
int *argc_ptr;
char ***argv_ptr;
{ char *p4pg_file = "procgroup";
  int i, p4pg_flag = 0;

#ifdef DEBUG
  system("hostname");
  printf("entering MPI_Init\n");
  printf(" argc: %d\n", *argc_ptr);
  printf("last argv: %s\n", (*argv_ptr)[*argc_ptr - 1]);
  fflush(stdout);
#endif
  
  /* eliminate broken socket exits */
  signal(SIGPIPE, sigpipe_handler);

  if ( sizeof(INT) != 4 ) {
    printf("sizeof(INT) != 4:  re-define INT in mpiimpl.h\n");
    exit(1);
  }

  if (MPINU_is_initialized) {
    printf("MPI_Init:  can't call MPI_Init after it's already started.\n");
    exit(1);
  }
  for( i = 0; i < PG_ARRAY_SIZE; i++ ) {
    MPINU_pg_array[i].processor = NULL; /* initialize all entries */
    MPINU_pg_array[i].sd = PG_NOSOCKET;
  }

  if ( 0 != strcmp( (*argv_ptr)[*argc_ptr - 1], "-p4amslave" )
       && ! MPINU_is_spawn2 ) {
    for( i = 0; i < *argc_ptr; i++ ) {
      if ( p4pg_flag )
	(*argv_ptr)[i] = (*argv_ptr)[i+2];
      else if ( ! strcmp( (*argv_ptr)[i], "-p4pg" ) ) {
        p4pg_file = (*argv_ptr)[i+1];
        i--;
        *argc_ptr -= 2;
        p4pg_flag = 1;
      }
    }
    if ( p4pg_flag ) (*argv_ptr)[*argc_ptr] = NULL;
#ifdef DEBUG
printf("p4pg_file: %s\n", p4pg_file);fflush(stdout);
#endif
    { struct stat buf;
      if ( 0 != stat( p4pg_file, &buf ) || ! buf.st_mode & S_IFREG
           || ! buf.st_mode & S_IRUSR ) {
        fprintf( stderr, "*** MPINU:  can't read procgroup file:  %s\n",
                 p4pg_file );
        if (  0 != strcmp( p4pg_file, "procgroup" ) ) {
	  fprintf( stderr,
		   "  Either create \"progroup\" in current directory:\n"
		   "    %s/procgroup\n",
		   getcwd( NULL, 256 ) );
	  fprintf( stderr,
		   "  or else add a command line arg:"
                      "  -p4pg  ABSOLUTE_PATH_OF_PROCGROUP_FILE\n");
        }
	return MPI_FAIL; 
      }
    }
    MPINU_mpi_master(p4pg_file, *argc_ptr, *argv_ptr);
    ssh_slaves = MPINU_num_slaves;
  }
  else {  /* else slave */
#ifdef DEBUG
    printf("calling MPINU_mpi_slave(%s, %s): %d\n",
	   (*argv_ptr)[*argc_ptr - 3], (*argv_ptr)[*argc_ptr - 2] );
    fflush(stdout);
#endif
    if ( MPINU_is_spawn2 ) MPINU_mpi_slave( NULL, NULL );
    else {
      MPINU_mpi_slave( (*argv_ptr)[*argc_ptr - 3], (*argv_ptr)[*argc_ptr - 2] );

      // Change command line arg:  -p4amslave => -p4rank:XX
      sprintf( (*argv_ptr)[*argc_ptr - 1], "-p4rank:%02d", MPINU_myrank%100 );

      *argc_ptr -= 3;
    }
  }
  MPINU_is_initialized = 1;

#if 1
  // Send message now to each slave, to initialize all-to-all connections
  // Replace this, when allowing connections to be set up on demand works.
  // To do that, have to add logic for case when two slaves each try
  //   to connect to each other at same time.  Can have rule like
  //   lower slave connects, higher slave accepts.  See file, TODO
  { int buf = 42;
    MPI_Status status;
    // Lower rank connects to higher rank; Higher rank process calls accept()
    // MPI_Send() will force all calls to connect()
//printf("buf: %x\n", &buf);
    if (MPINU_myrank > 0 && MPINU_myrank < MPINU_num_slaves)
      for (i = MPINU_myrank+1; i <= MPINU_num_slaves; i++)
        MPI_Send(&buf, 1, MPI_INT, i, 111, MPI_COMM_WORLD);
    // MPI_Recv() will force all calls to accept()
    if (MPINU_myrank > 1)
      for (i = 1; i < MPINU_myrank; i++) {
        MPI_Recv(&buf, 1, MPI_INT, i, 111, MPI_COMM_WORLD, &status);
        MPI_Send(&buf, 1, MPI_INT, i, 111, MPI_COMM_WORLD);
      }
    // Confirm to connector that accept() is complete
    if (MPINU_myrank > 0 && MPINU_myrank < MPINU_num_slaves)
      for (i = MPINU_myrank+1; i <= MPINU_num_slaves; i++)
        MPI_Recv(&buf, 1, MPI_INT, i, 111, MPI_COMM_WORLD, &status);
  }
#endif
  return MPI_SUCCESS;
}

int MPI_Initialized( flag )
     int *flag;
{ *flag = MPINU_is_initialized;
  return MPI_SUCCESS;
}

int MPI_Finalize()
{ int i, statusp;
  MPI_Status status;

  MPINU_coll_comm_flag = 1;
  if (MPINU_myrank == 0)
    for (i = 1; i <= MPINU_num_slaves; i++)
      MPI_Send(&i, 1, MPI_INT, i, MPI_COLL_COMM_TAG, MPI_COMM_WORLD);
  else
    MPI_Recv(&i, 1, MPI_INT, 0, MPI_COLL_COMM_TAG, MPI_COMM_WORLD, &status);
  MPINU_coll_comm_flag = 0;
  MPINU_send_thread_exit();

  MPINU_is_initialized = 0;
  for (i = 0; i<= MPINU_num_slaves; i++)
    if ( MPINU_pg_array[i].sd != PG_NOSOCKET )
      if ( close(MPINU_pg_array[i].sd) )
	perror("MPINU: MPI_Finalize: close"); // but don't exit
  if ( close(MPINU_my_list_sd) )
    perror("MPINU: MPI_Finalize: close"); // but don't exit
  if (MPINU_myrank == 0) /* master waits for slaves to finish */
    for (i = 1; i<= ssh_slaves; i++)
      CALL_CHK( wait, (&statusp) );
  return MPI_SUCCESS;
}

/* Fill in all three on exit */
int MPINU_new_listener(sd, sin, port)
int *sd, *port;
struct sockaddr_in *sin;       /* inet info structure            */
{ char host[256];		/* hostname for this process      */
  struct hostent *hp;           /* ptr to host info structure     */
  socklen_t socklen;
  int i;

  /* use the default protocol 6 = IPPROTO_TCP */
  *sd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  SETSOCKOPT(*sd);
  /* Add new socket descriptor to set of all socket descriptors */
  FD_SET( *sd, &MPINU_fdset );
  if ( *sd > MPINU_max_sd )
    MPINU_max_sd = *sd;
#ifdef DEBUG
  printf("MPINU_new_listener: socket: %d\n", *sd);fflush(stdout);
#endif

  CALL_CHK(gethostname, (host, 256));
  hp = gethostbyname(host);

#if 0
  memset( (char *)sin, (char)0, sizeof(*sin) );
#else
  for ( i = 0; i < (signed)sizeof(*sin); i++ )
    ((char *)sin)[i] = 0;
#endif

  /* Is this next line (h_addr) needed? */
  memcpy( (char *)&(sin->sin_addr), hp->h_addr, hp->h_length);
  sin->sin_port = htons(0);
  sin->sin_family = hp->h_addrtype;
  /* Since INADDR_ANY is 0, zeroing out sin accomplished this, anyway. */
  sin->sin_addr.s_addr = INADDR_ANY;

#if 0
  printf("sin_family (%d) and AF_INET (%d) should compare.\n", sin->sin_family, AF_INET);
  printf("master: hp->h_name: %s\n", hp->h_name);
#endif

  do {
    sin->sin_addr.s_addr = INADDR_ANY;
    CALL_CHK( bind, (*sd, (struct sockaddr *)sin, sizeof(*sin)) );
    /* CALL_CHK sets errno = 0; O/S sometimes assigns a stale address */
  } while(errno == EADDRINUSE);

  /* i acts as dummy for sin_len below */
  socklen = sizeof(struct sockaddr_in);
  CALL_CHK( getsockname, (*sd, (struct sockaddr *)sin, &socklen) );
  *port = ntohs(sin->sin_port);
#ifdef DEBUG
  printf("MPINU_new_listener: port: %d == %d; sin_len: %d\n",
	 ntohs(sin->sin_port), *port, i); fflush(stdout);
#endif
  if ( sin->sin_port == 0 ) {
    printf("LISTENER FAILED TO GET NEW PORT!!\n");
    exit(1);
  }

  /* Under SunOS 4.1, SOMAXCONN = 5; Could have slaves re-try after timeout */
  CALL_CHK( listen, (*sd, SOMAXCONN) );
  /* On Solaris 2.6, getsockname (and maybe bind?) zero out sin->sin_addr
    (converting it to localhost for efficiency?); So copy it back in */
  memcpy( (char *)&(sin->sin_addr), hp->h_addr, hp->h_length);
  return 0;
}
