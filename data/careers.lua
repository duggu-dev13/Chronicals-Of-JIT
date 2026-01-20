local Careers = {
    professor = {
        name = "Professor Path",
        subPaths = {
            job = {
                name = "Academic Career",
                description = "Climb the ladder of academic excellence.",
                ranks = {
                    { title = "Lab Assistant", req = { knowledge = 10, reputation = 0 } },
                    { title = "Lecturer", req = { knowledge = 50, reputation = 10 } },
                    { title = "Assistant Professor", req = { knowledge = 150, reputation = 30 } },
                    { title = "Associate Professor", req = { knowledge = 300, reputation = 60 } },
                    { title = "Professor", req = { knowledge = 500, reputation = 100 } },
                    { title = "HOD", req = { knowledge = 800, reputation = 200 } },
                    { title = "Principal", req = { knowledge = 1200, reputation = 400 } },
                    { title = "Dean", req = { knowledge = 1800, reputation = 700 } },
                    { title = "Vice-Chancellor", req = { knowledge = 3000, reputation = 1000 } }
                }
            },
            business = {
                name = "Educational Entrepreneur",
                description = "Monetize your knowledge to build an empire.",
                ranks = {
                    { title = "Online Tutor", req = { innovation = 10, money = 100 } },
                    { title = "Content Creator", req = { innovation = 50, money = 500 } },
                    { title = "Sole Proprietor", req = { innovation = 100, money = 2000 } },
                    { title = "Small Firm Owner", req = { innovation = 300, money = 10000 } },
                    { title = "Corporation CEO", req = { innovation = 600, money = 50000 } },
                    { title = "Group Chairman", req = { innovation = 1500, money = 200000 } },
                    { title = "Education Minister", req = { innovation = 5000, reputation = 2000 } } -- Ultimate Goal
                }
            }
        }
    },
    student = {
        name = "Student Path",
        subPaths = {
            specialization = {
                name = "Startup & Innovation",
                description = "Create new solutions in Agriculture or Manufacturing.",
                ranks = {
                    { title = "Idea Stage", req = { innovation = 20 } },
                    { title = "Startup Founder", req = { innovation = 100, knowledge = 50 } },
                    { title = "Small Firm", req = { innovation = 300, money = 5000 } },
                    { title = "Local Business", req = { innovation = 600, money = 20000 } },
                    { title = "International Biz", req = { innovation = 1500, money = 100000 } },
                    { title = "Global Leader", req = { innovation = 5000, money = 1000000 } }
                }
            },
            department = {
                name = "Corporate Engineering",
                description = "Work in Civil, Mech, CS, or Electrical sectors.",
                ranks = {
                    { title = "Intern", req = { knowledge = 30 } },
                    { title = "Trainee", req = { knowledge = 80 } },
                    { title = "Assistant Engineer", req = { knowledge = 200 } },
                    { title = "Employee", req = { knowledge = 400 } },
                    { title = "Senior Engineer", req = { knowledge = 800 } },
                    { title = "Manager", req = { knowledge = 1500 } }
                }
            }
        }
    }
}

return Careers
