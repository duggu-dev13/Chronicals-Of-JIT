-- Career Path Configuration
-- Defines ranks, salaries, and promotion requirements for each path

local Careers = {
    student = {
        title = "Student",
        ranks = {
            [1] = {
                id = "freshman",
                title = "Freshman",
                salary = 0,
                desc = "First year student. Focus on basics.",
                req = {} -- Starting rank
            },
            [2] = {
                id = "sophomore",
                title = "Sophomore",
                salary = 50, -- Stipend/Internship
                desc = "Second year. Eligible for basic internships.",
                req = {
                    knowledge = 100,
                    examsPassed = 1
                }
            },
            [3] = {
                id = "junior",
                title = "Junior Engineer",
                salary = 150, -- Paid Intern
                desc = "Third year. working on real projects.",
                req = {
                    knowledge = 300,
                    reputation = 20
                }
            },
            [4] = {
                id = "senior",
                title = "Senior Engineer",
                salary = 500, -- Freelance/Job
                desc = "Final year. Job ready.",
                req = {
                    knowledge = 600,
                    reputation = 50,
                    examsPassed = 3
                }
            }
        }
    },
    
    professor = {
        title = "Academic",
        ranks = {
            [1] = {
                id = "assistant",
                title = "Lab Assistant",
                salary = 200,
                desc = "Helping with lab work and grading.",
                req = {}
            },
            [2] = {
                id = "lecturer",
                title = "Lecturer",
                salary = 500,
                desc = "Conducting classes and lectures.",
                req = {
                    knowledge = 200, -- Needs to know stuff to teach
                    reputation = 50
                }
            },
            [3] = {
                id = "hod",
                title = "Head of Dept",
                salary = 1200,
                desc = "Managing the entire department.",
                req = {
                    knowledge = 800,
                    reputation = 200,
                    integrity = 80
                }
            }
        }
    }
}

return Careers
