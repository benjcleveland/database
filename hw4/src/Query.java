/*
 * Ben Cleveland
 * CSEP 544
 * Homework 4 
 * 
 */

import java.util.Properties;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import java.io.FileInputStream;

/**
 * Runs queries against a back-end database
 */
public class Query {
	private String configFilename;
	private Properties configProps = new Properties();

	private String jSQLDriver;
	private String jSQLUrl;
	private String jSQLUser;
	private String jSQLPassword;

	// DB Connection
	private Connection conn;
    private Connection customerConn;

	// Canned queries

	// LIKE does a case-insensitive match
	private static final String SEARCH_SQL = "SELECT * " 
			+ "FROM movie "
			+ "WHERE name LIKE ? ORDER BY id";
	private PreparedStatement searchMovieStatement;
	
	private static final String DIRECTOR_MID_SQL = "SELECT y.* "
					 + "FROM movie_directors x, directors y "
					 + "WHERE x.mid = ? and x.did = y.id";
	private PreparedStatement directorMidStatement;
	
	private static final String ACTOR_MID_SQL = "SELECT a.* "
					+ "FROM actor a, casts c " 
					+ "WHERE a.id = c.pid and c.mid = ?";
	private PreparedStatement actorMidStatement;
	
	private static final String DIRECTOR_MOVIE_SQL = "SELECT m.id, y.* "
					 + "FROM movie_directors x, directors y, movie m "
					 + "WHERE x.mid = m.id and x.did = y.id and m.name like ? "
					 + "ORDER BY m.id";
	private PreparedStatement directorMovieStatement;
	
	private static final String ACTOR_MOVIE_SQL = "SELECT m.id, a.* "
					+ "FROM actor a, casts c, movie m " 
					+ "WHERE a.id = c.pid and c.mid = m.id and m.name like ? "
					+ "ORDER BY	m.id";
	private PreparedStatement actorMovieStatement;
	
	private static final String RENTAL_MID_SQL = "SELECT r.* "
			+ "FROM rentals r "
			+ "WHERE r.movie_id = ? and r.status != 'closed'";
	private PreparedStatement rentalMidStatement;

	/* uncomment, and edit, after your create your own customer database */
	private static final String CUSTOMER_LOGIN_SQL = 
		"SELECT * FROM customer WHERE login = ? and password like ?";
	private PreparedStatement customerLoginStatement;

	private static final String BEGIN_TRANSACTION_SQL = 
		"SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; BEGIN TRANSACTION;";
	private PreparedStatement beginTransactionStatement;

	private static final String COMMIT_SQL = "COMMIT TRANSACTION";
	private PreparedStatement commitTransactionStatement;

	private static final String ROLLBACK_SQL = "ROLLBACK TRANSACTION";
	private PreparedStatement rollbackTransactionStatement;
	
	private static final String CUSTOMER_NAME_SQL = "SELECT * "
			+ "FROM customer "
			+ "WHERE id = ?";
	private PreparedStatement customerNameStatement;

	private static final String CUSTOMER_PLAN_SQL = "SELECT p.* "
			+ "FROM customer c, plans p "
			+ "WHERE c.plan_id = p.id and c.id = ?";
	private PreparedStatement customerPlanStatement;
	
	private static final String CUSTOMER_RENTALS_SQL = "SELECT count(*) as num_rentals "
			+ "FROM customer c, rentals r "
			+ "WHERE c.id = r.cust_id and c.id = ? and r.status = 'open'";
	private PreparedStatement customerRentalStatement;
	
	private static final String PLANS_SQL = "SELECT * FROM plans";
	private PreparedStatement plansStatement;
	
	private static final String VALID_PLAN_SQL = "SELECT * "
			+ "FROM plans WHERE id = ?";
	private PreparedStatement validPlanStatement;
	
	private static final String UPDATE_PLAN_SQL = "UPDATE customer "
			+ "SET plan_id = ? "
			+ "WHERE id = ?";
	private PreparedStatement updatePlanStatement;
	
	private static final String VALID_MOVIE_SQL = "SELECT * "
			+ "FROM movie WHERE id = ?"; 
	private PreparedStatement validMovieStatement;
	
	private static final String NUM_RENTERS_SQL = "SELECT count(*) "
			+ "FROM rentals "
			+ "WHERE movie_id = ? and status = 'open'";
	private PreparedStatement numRentersStatement;
	
	private static final String RENT_MOVIE_SQL = "INSERT INTO rentals "
			+ "VALUES (?, ?, 'open', current_timestamp)";
	private PreparedStatement rentMovieStatement;
	
	private static final String MOVIE_RENTER_SQL = "SELECT cust_id "
			+ "FROM rentals "
			+ "where movie_id = ? and status = 'open'";
	private PreparedStatement movieRenterStatement;
	
	private static final String RETURN_MOVIE_SQL = "UPDATE rentals "
			+ "SET status = 'closed' "
			+ "WHERE cust_id = ? and movie_id = ? and status = 'open'";
	private PreparedStatement returnMovieStatement;
	
	public Query(String configFilename) {
		this.configFilename = configFilename;
	}

    /**********************************************************/
    /* Connection code to SQL Azure. Example code below will connect to the imdb database on Azure
       IMPORTANT NOTE:  You will need to create (and connect to) your new customer database before 
       uncommenting and running the query statements in this file .
     */

	public void openConnection() throws Exception {
		configProps.load(new FileInputStream(configFilename));

		jSQLDriver   = configProps.getProperty("videostore.jdbc_driver");
		jSQLUrl	   = configProps.getProperty("videostore.imdb_url");
		jSQLUser	   = configProps.getProperty("videostore.sqlazure_username");
		jSQLPassword = configProps.getProperty("videostore.sqlazure_password");


		/* load jdbc drivers */
		Class.forName(jSQLDriver).newInstance();

		/* open connections to the imdb database */

		conn = DriverManager.getConnection(jSQLUrl, // database
						   jSQLUser, // user
						   jSQLPassword); // password
                
		conn.setAutoCommit(true); //by default automatically commit after each statement 

		/* You will also want to appropriately set the 
                   transaction's isolation level through:  
		   conn.setTransactionIsolation(...) */
		conn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);

		/* Also you will put code here to specify the connection to your
		   customer DB.  E.g.

		   customerConn = DriverManager.getConnection(...);
		   customerConn.setAutoCommit(true); //by default automatically commit after each statement
		   customerConn.setTransactionIsolation(...); //
		*/
		
		jSQLUrl	   = configProps.getProperty("videostore.customer_url");


		/* load jdbc drivers */
		Class.forName(jSQLDriver).newInstance();

		/* open connections to the imdb database */

		customerConn = DriverManager.getConnection(jSQLUrl, // database
						   jSQLUser, // user
						   jSQLPassword); // password
                
		customerConn.setAutoCommit(true); //by default automatically commit after each statement 
		customerConn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
	}

	public void closeConnection() throws Exception {
		conn.close();
		customerConn.close();
	}

    /**********************************************************/
    /* prepare all the SQL statements in this method.
      "preparing" a statement is almost like compiling it.  Note
       that the parameters (with ?) are still not filled in */

	public void prepareStatements() throws Exception {

		searchMovieStatement = conn.prepareStatement(SEARCH_SQL);
		directorMidStatement = conn.prepareStatement(DIRECTOR_MID_SQL);
		directorMovieStatement = conn.prepareStatement(DIRECTOR_MOVIE_SQL);
		validMovieStatement = conn.prepareStatement(VALID_MOVIE_SQL);

		/* uncomment after you create your customers database */
		customerLoginStatement = customerConn.prepareStatement(CUSTOMER_LOGIN_SQL);
		beginTransactionStatement = customerConn.prepareStatement(BEGIN_TRANSACTION_SQL);
		commitTransactionStatement = customerConn.prepareStatement(COMMIT_SQL);
		rollbackTransactionStatement = customerConn.prepareStatement(ROLLBACK_SQL);

		/* add here more prepare statements for all the other queries you need */
		actorMidStatement = conn.prepareStatement(ACTOR_MID_SQL);
		actorMovieStatement = conn.prepareStatement(ACTOR_MOVIE_SQL);
		
		rentalMidStatement = customerConn.prepareStatement(RENTAL_MID_SQL);
		customerNameStatement = customerConn.prepareStatement(CUSTOMER_NAME_SQL);
		customerPlanStatement = customerConn.prepareStatement(CUSTOMER_PLAN_SQL);
		customerRentalStatement = customerConn.prepareStatement(CUSTOMER_RENTALS_SQL);
		plansStatement = customerConn.prepareStatement(PLANS_SQL);
		validPlanStatement = customerConn.prepareStatement(VALID_PLAN_SQL);
		updatePlanStatement = customerConn.prepareStatement(UPDATE_PLAN_SQL);
		numRentersStatement = customerConn.prepareStatement(NUM_RENTERS_SQL);
		rentMovieStatement = customerConn.prepareStatement(RENT_MOVIE_SQL);
		movieRenterStatement = customerConn.prepareStatement(MOVIE_RENTER_SQL);
		returnMovieStatement = customerConn.prepareStatement(RETURN_MOVIE_SQL);
	}


    /**********************************************************/
    /* Suggested helper functions; you can complete these, or write your own
       (but remember to delete the ones you are not using!) */

	public int getRemainingRentals(int cid) throws Exception {
		/* How many movies can she/he still rent?
		   You have to compute and return the difference between the customer's plan
		   and the count of outstanding rentals */
		int max_rentals = 0;
		int curr_rentals = 0;
		
		customerPlanStatement.clearParameters();
		customerPlanStatement.setInt(1, cid);
		ResultSet plan_set = customerPlanStatement.executeQuery();
		
		if(plan_set.next())
			max_rentals = plan_set.getInt("max_rentals");
		plan_set.close();
		
		customerRentalStatement.clearParameters();
		customerRentalStatement.setInt(1, cid);
		ResultSet rental_set = customerRentalStatement.executeQuery();
		
		if(rental_set.next())
			curr_rentals = rental_set.getInt("num_rentals");
		
		rental_set.close();
		
		// determine the number of outstanding rentals
		return (max_rentals - curr_rentals);
	}

	public String getCustomerName(int cid) throws Exception {
		/* Find the first and last name of the current customer. */
		String name = "Unknown Name";
		
		customerNameStatement.clearParameters();
		customerNameStatement.setInt(1, cid);
		ResultSet name_set = customerNameStatement.executeQuery();
		if (name_set.next())
			name = name_set.getString("firstname") + " " + name_set.getString("lastname");
		
		name_set.close();
		return name; 
	}

	public boolean isValidPlan(int planid) throws Exception {
		/* Is planid a valid plan ID?  You have to figure it out */
		boolean valid_plan = false;
		validPlanStatement.clearParameters();
		validPlanStatement.setInt(1, planid);
		ResultSet valid_set = validPlanStatement.executeQuery();
		if(valid_set.next())
			valid_plan = true;
		valid_set.close();
		
		return valid_plan;
	}

	public boolean isValidMovie(int mid) throws Exception {
		/* is mid a valid movie ID?  You have to figure it out */
		boolean valid_movie = false;
		validMovieStatement.clearParameters();
		validMovieStatement.setInt(1, mid);
		ResultSet valid_set = validMovieStatement.executeQuery();
		if(valid_set.next())
			valid_movie = true;
		valid_set.close();
		return valid_movie;
	}
	
	private int getNumRenters(int mid) throws Exception {
		/* finds the number of renters currently renting a movie */
		int num_renters = 0;
		numRentersStatement.clearParameters();
		numRentersStatement.setInt(1, mid);
		ResultSet renters_set = numRentersStatement.executeQuery();
		if(renters_set.next())
			num_renters = renters_set.getInt(1);
		
		renters_set.close();
		return num_renters;
	}

	private int getRenterID(int mid) throws Exception {
		/* Find the customer id (cid) of whoever currently rents the movie mid; return -1 if none */
		int customer_id = -1;
		movieRenterStatement.clearParameters();
		movieRenterStatement.setInt(1, mid);
		ResultSet renter_set = movieRenterStatement.executeQuery();
		if(renter_set.next())
			customer_id = renter_set.getInt("cust_id");
		renter_set.close();
		return customer_id;
	}

    /**********************************************************/
    /* login transaction: invoked only once, when the app is started  */
	public int transaction_login(String name, String password) throws Exception {
		/* authenticates the user, and returns the user id, or -1 if authentication fails */

		/* Uncomment after you create your own customers database */
		int cid;

		customerLoginStatement.clearParameters();
		customerLoginStatement.setString(1,name);
		customerLoginStatement.setString(2,password);
		ResultSet cid_set = customerLoginStatement.executeQuery();
		if (cid_set.next()) 
			cid = cid_set.getInt(1);
		else 
			cid = -1;
		
		cid_set.close();
			
		return(cid);
	}

	public void transaction_printPersonalData(int cid) throws Exception {
		/* println the customer's personal data: name, and plan number */
		
		System.out.println(getCustomerName(cid));
		System.out.println("Remaining Rentals: " + getRemainingRentals(cid));
	}


    /**********************************************************/
    /* main functions in this project: */

	public void transaction_search(int cid, String movie_title)
			throws Exception {
		/* searches for movies with matching titles: SELECT * FROM movie WHERE name LIKE movie_title */
		/* prints the movies, directors, actors, and the availability status:
		   AVAILABLE, or UNAVAILABLE, or YOU CURRENTLY RENT IT */

		/* Interpolate the movie title into the SQL string */
		searchMovieStatement.clearParameters();
		searchMovieStatement.setString(1, "%" + movie_title + "%");
		ResultSet movie_set = searchMovieStatement.executeQuery();
		while (movie_set.next()) {
			int mid = movie_set.getInt(1);
			System.out.println("ID: " + mid + " NAME: "
					+ movie_set.getString(2) + " YEAR: "
					+ movie_set.getString(3));
			/* do a dependent join with directors */
			directorMidStatement.clearParameters();
			directorMidStatement.setInt(1, mid);
			ResultSet director_set = directorMidStatement.executeQuery();
			while (director_set.next()) {
				System.out.println("\t\tDirector: " + director_set.getString(3)
						+ " " + director_set.getString(2));
			}
			director_set.close();
			
			/* now you need to retrieve the actors, in the same manner */
			actorMidStatement.clearParameters();
			actorMidStatement.setInt(1, mid);
			ResultSet actor_set = actorMidStatement.executeQuery();
			while(actor_set.next()) {
				System.out.println("\t\tActor: " + actor_set.getString(2)
						+ " " + actor_set.getString(3));
			}
			actor_set.close();
			
			/* then you have to find the status: of "AVAILABLE" "YOU HAVE IT", "UNAVAILABLE" */
			rentalMidStatement.clearParameters();
			rentalMidStatement.setInt(1, mid);
			ResultSet rental_set = rentalMidStatement.executeQuery();
			String rental_status = "AVAILABLE";
			while(rental_set.next()) {
				if(rental_set.getInt("cust_id") == cid)
					rental_status = "YOU CURRENTLY HAVE IT";
				else
					rental_status = "UNAVAILABLE";
			}
			System.out.println("\t\tRental Status: " + rental_status);
			rental_set.close();
		}
		movie_set.close();
		System.out.println();
	}

	public void transaction_choosePlan(int cid, int pid) throws Exception {
	    /* updates the customer's plan to pid: UPDATE customer SET plid = pid */
	    /* remember to enforce consistency ! */
		beginTransaction();
		
		// update the plan
		updatePlanStatement.clearParameters();
		updatePlanStatement.setInt(1, pid);
		updatePlanStatement.setInt(2, cid);
		updatePlanStatement.executeUpdate();
		
		// get the number of rentals
		if(getRemainingRentals(cid) < 0) {
			rollbackTransaction();
			System.out.println("Cannot choose this plan because you have too many rentals.");
			System.out.println("Please return movies to change to this plan.");
		}
		else
			commitTransaction();
	}

	public void transaction_listPlans() throws Exception {
	    /* println all available plans: SELECT * FROM plan */
		ResultSet plan_set = plansStatement.executeQuery();
		while(plan_set.next()) {
			System.out.println("Plan ID: " + plan_set.getString("id")); 
			System.out.println("\tName: " + plan_set.getString("name")); 
			System.out.println("\tMax Rentals: " + plan_set.getInt("max_rentals"));
			System.out.println("\tPrice: $" + String.format( "%.2f", plan_set.getDouble("monthly_fee")));
		}
		plan_set.close();
	}

	public void transaction_rent(int cid, int mid) throws Exception {
	    /* rent the movie mid to the customer cid */
	    /* remember to enforce consistency ! */
		// make sure the movie is valid
		if(isValidMovie(mid) == false) {
			System.out.println("You choose an invalid movie id...");
			return;
		}
		
		beginTransaction();
		
		// insert into the rentals list
		rentMovieStatement.clearParameters();
		rentMovieStatement.setInt(1, cid);
		rentMovieStatement.setInt(2, mid);
		rentMovieStatement.executeUpdate();
		
		// make sure no one else is renting this movie
		if(getNumRenters(mid) != 1) {
			rollbackTransaction();
			System.out.println("Sorry, this moive has already been rented...");
		} else if(getRemainingRentals(cid) < 0) {
			// make sure we are not over our limit
			rollbackTransaction();
			System.out.println("Sorry, you are at your rental limit, return movies or upgrade your plan to rent more!");
		} else {	
			commitTransaction();
		}
	}

	public void transaction_return(int cid, int mid) throws Exception {
	    /* return the movie mid by the customer cid */
		if(isValidMovie(mid) == false) {
			System.out.println("You choose an invalid movie id...");
			return;
		}
		
		// make sure the customer currently has the movie rented
		if(getRenterID(mid) == cid) {
			// set the movie as returned
			returnMovieStatement.clearParameters();
			returnMovieStatement.setInt(1, cid);
			returnMovieStatement.setInt(2, mid);
			returnMovieStatement.executeUpdate();
		} else {
			System.out.println("You do not currently have this movie rented.");
		}
	}

	public void transaction_fastSearch(int cid, String movie_title)
			throws Exception {
		/* like transaction_search, but uses joins instead of dependent joins
		   Needs to run three SQL queries: (a) movies, (b) movies join directors, (c) movies join actors
		   Answers are sorted by mid.
		   Then merge-joins the three answer sets */
		
		/* Interpolate the movie title into the SQL string */
		searchMovieStatement.clearParameters();
		searchMovieStatement.setString(1, "%" + movie_title + "%");
		ResultSet movie_set = searchMovieStatement.executeQuery();
		
		directorMovieStatement.clearParameters();
		directorMovieStatement.setString(1, "%" + movie_title + "%");
		ResultSet director_set = directorMovieStatement.executeQuery();
		director_set.next();

		actorMovieStatement.clearParameters();
		actorMovieStatement.setString(1, "%" + movie_title + "%");
		ResultSet actor_set = actorMovieStatement.executeQuery();
		actor_set.next();
		
		// do the 'merge-join'
		while(movie_set.next()) {
			int mid = movie_set.getInt(1);
			System.out.println("ID: " + mid + " NAME: "
					+ movie_set.getString(2) + " YEAR: "
					+ movie_set.getString(3));
			
			/* do a merge-join with directors */
			if(director_set.isAfterLast() == false) {
				while (director_set.getInt(1) == mid) {
					System.out.println("\t\tDirector: " + director_set.getString(4)
							+ " " + director_set.getString(3));
					if(!director_set.next())
						break;
				}
			}
			
			/* now you need to retrieve the actors, in the same manner */
			if(actor_set.isAfterLast() == false) {
				while(actor_set.getInt(1) == mid) {
					System.out.println("\t\tActor: " + actor_set.getString("fname")
							+ " " + actor_set.getString("lname"));
					if(!actor_set.next())
						break;
				}
			}
		}
		
		movie_set.close();
		director_set.close();
		actor_set.close();
	}


    /* Uncomment helpers below once you've got beginTransactionStatement,
       commitTransactionStatement, and rollbackTransactionStatement setup from
       prepareStatements():
    */
	public void beginTransaction() throws Exception {
	    customerConn.setAutoCommit(false);
	    beginTransactionStatement.executeUpdate();	
    }

    public void commitTransaction() throws Exception {
	    commitTransactionStatement.executeUpdate();	
	    customerConn.setAutoCommit(true);
    }
    public void rollbackTransaction() throws Exception {
	    rollbackTransactionStatement.executeUpdate();
	    customerConn.setAutoCommit(true);
	} 
}