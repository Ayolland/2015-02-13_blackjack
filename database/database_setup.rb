DATABASE.results_as_hash = true
DATABASE.execute("CREATE TABLE IF NOT EXISTS Users
                   (id INTEGER PRIMARY KEY,
                    username TEXT,
                    password TEXT,
                    name TEXT,
                    gender TEXT,
                    chips INTEGER)")
DATABASE.execute("CREATE TABLE IF NOT EXISTS Qualities
                   (id INTEGER PRIMARY KEY,
                    name TEXT)")
DATABASE.execute("CREATE TABLE IF NOT EXISTS UserQualities
                   (id INTEGER PRIMARY KEY,
                    user_id INTEGER,
                    quality_id INTEGER)")
                    
# DATABASE.execute("CREATE TABLE IF NOT EXISTS Dealers
#                    (id INTEGER PRIMARY KEY,
#                     user_id_1 INTEGER,
#                     user_id_2 INTEGER,
#                     user_id_3 INTEGER,
#                     user_id_4 INTEGER,
#                     user_id_5 INTEGER,)")                    
# DATABASE.execute("CREATE TABLE IF NOT EXISTS UserCards
#                    (id INTEGER PRIMARY KEY,
#                     card TEXT,
#                     user_id INTEGER)")
# DATABASE.execute("CREATE TABLE IF NOT EXISTS DealerCards
#                    (id INTEGER PRIMARY KEY,
#                     card TEXT,
#                     table_id INTEGER)")
# DATABASE.execute("CREATE TABLE IF NOT EXISTS Bet
#                     (id INTEGER PRIMARY KEY,
#                      bet INTEGER)")
                     
                     #TODO replace these tables
DATABASE.execute("CREATE TABLE IF NOT EXISTS Dealer
                   (id INTEGER PRIMARY KEY,
                    card TEXT)")
DATABASE.execute("CREATE TABLE IF NOT EXISTS Player
                   (id INTEGER PRIMARY KEY,
                    card TEXT)")

  
                    