local CharacterConfigs = {
    student = {
        sheet = 'sprites/Player/Student_1_Walk_Full_Compose-Sheet_SpriteSheet.png',
        frameWidth = 64,
        frameHeight = 64,
        rows = { right = 1, left = 2, down = 3, up = 4 },
        animSpeed = 0.1,
        scaleFactor = 0.66,
        footstepSound = 'sounds/female_footsteps.mp3'
    },
    teacher = {
        sheet = 'sprites/Player/professor_1_Walk_Full_Compose-Sheet_SpriteSheet.png',
        frameWidth = 64,
        frameHeight = 64,
        rows = { right = 1, left = 2, down = 3, up = 4 },
        animSpeed = 0.1,
        scaleFactor = 0.66,
        footstepSound = 'sounds/female_footsteps.mp3'
    }
}

return CharacterConfigs
