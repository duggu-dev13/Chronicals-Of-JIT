# Base imports
import pygame, sys, os
from pygame.locals import *
from PIL import Image

# Initialize game
pygame.init()
monitor_size = [pygame.display.Info().current_w, pygame.display.Info().current_h]
screen = pygame.display.set_mode((500, 500), pygame.RESIZABLE)
pygame.display.set_caption("Base Game")
mainClock = pygame.time.Clock()

# Game variables
fullscreen = False
frame_delay = 100  # milliseconds between frames
last_frame_time = pygame.time.get_ticks()
current_frame = 0
move_speed = 2  # pixels per frame

# Load images into a list
image_list = []
for load_image in sorted(os.listdir("frames")):
    if load_image.endswith(".png"):
        img = pygame.image.load(os.path.join("frames", load_image)).convert_alpha()
        img = pygame.transform.scale(img, (100, 100))
        image_list.append(img)

# Character rect (position and size)
char_rect = image_list[0].get_rect(midbottom=(screen.get_width() // 2, screen.get_height() // 2))

# Game loop
while True:
    mainClock.tick(60)
    screen.fill((0, 0, 50))
    keys = pygame.key.get_pressed()
    now = pygame.time.get_ticks()

    moving = False  # Flag to check if character is moving

    # Movement and animation logic
    if keys[K_w]:
        char_rect.y -= move_speed
        moving = True
    if keys[K_s]:
        char_rect.y += move_speed
        moving = True
    if keys[K_a]:
        char_rect.x -= move_speed
        moving = True
    if keys[K_d]:
        char_rect.x += move_speed
        moving = True

    # Animation frame update only while moving
    if moving:
        if now - last_frame_time >= frame_delay:
            current_frame = (current_frame + 1) % len(image_list)
            last_frame_time = now
        screen.blit(image_list[current_frame], char_rect)
    else:
        screen.blit(image_list[0], char_rect)  # Idle frame

    # Handle events
    for event in pygame.event.get():
        if event.type == QUIT:
            pygame.quit()
            sys.exit()

        if event.type == VIDEORESIZE:
            if not fullscreen:
                screen = pygame.display.set_mode((event.w, event.h), pygame.RESIZABLE)

        if event.type == KEYDOWN:
            if event.key == K_ESCAPE:
                pygame.quit()
                sys.exit()
            elif event.key == K_f:
                fullscreen = not fullscreen
                if fullscreen:
                    screen = pygame.display.set_mode(monitor_size, pygame.FULLSCREEN)
                else:
                    screen = pygame.display.set_mode((screen.get_width(), screen.get_height()), pygame.RESIZABLE)

    pygame.display.flip()
