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
                    quality_id INTEGER,
                    date INTEGER)")
                     
     #TODO replace these tables !!DONE by moving to sessions...
DATABASE.execute("CREATE TABLE IF NOT EXISTS Dealer
                   (id INTEGER PRIMARY KEY,
                    card TEXT)")
DATABASE.execute("CREATE TABLE IF NOT EXISTS Player
                   (id INTEGER PRIMARY KEY,
                    card TEXT)")

  
                    