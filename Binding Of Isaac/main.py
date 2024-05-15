import pygame
from sys import exit
from Menu_button import Button
import time
from Hero import Hero
from Mob_spawn import add_mob, mobs, obstacles, add_boss, add_obstacle
from Weapons import *
from Obstacle import *
from Boss import *

pygame.init()
music = pygame.mixer.music.load("assets/Sound/game track.mp3")
pygame.mixer.music.play(-1)
pygame.mixer.music.set_volume(0.1)
width, height = 1280, 720

screen = pygame.display.set_mode((width, height))
pygame.display.set_caption("Binding of Isaac")

fps = pygame.time.Clock()
pause = False
font = pygame.font.Font('assets/font/Hammer God Font DEMO.ttf', 36)
projectiles = pygame.sprite.Group()

BG = pygame.image.load("assets/Graphics/background.png")
BG = pygame.transform.scale(BG, (width, height))

hero = Hero("Entitys/Mobs/Hero/hero.json")
all_sprites = pygame.sprite.Group()
all_sprites.add(hero)


def pause_menu(screen, paused):
    resume_button = Button(image=None, pos=(width // 2, height // 2 - 100), text_input='Press r to Resume', font=font, base_color=(255, 255, 255), hovering_color='Green')
    save_button = Button(image=None, pos=(width // 2, height // 2), text_input='Press s to Save', font=font, base_color=(255, 255, 255), hovering_color='Green')
    quit_button = Button(image=None, pos=(width // 2, height // 2 + 100), text_input='Press q to Quit', font=font, base_color=(255, 255, 255), hovering_color='Green')


    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                exit()
            if event.type == pygame.MOUSEBUTTONDOWN:
                if resume_button.checkForInput(pygame.mouse.get_pos()):
                    return
                if save_button.checkForInput(pygame.mouse.get_pos()):
                    save_game()
                if quit_button.checkForInput(pygame.mouse.get_pos()):
                    pygame.quit()
                    exit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_r:
                    return
                if event.key == pygame.K_s:
                    save_game()
                if event.key == pygame.K_q:
                    pygame.quit()
                    exit()

        screen.blit(paused, (0, 0))
        resume_button.update(screen)
        save_button.update(screen)
        quit_button.update(screen)

        pygame.display.update()
        fps.tick(60)


def save_game():
    # Implement your save game logic here
    pass


def game(screen, pause=False):
    original_screen = screen.copy()
    boss_spawned = False
    if hero.in_boss_room:
        if not boss_spawned and len(mobs) == 0:
            add_boss(hero)
            boss_spawned = True
    else:
        while len(mobs) < 5:
            add_mob(hero)
    while len(obstacles) < 2:
        add_obstacle(hero)

    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                exit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_p:
                    pygame.image.save(screen, 'pause.png')

                    # Load the screenshot
                    screenshot = pygame.image.load('pause.png')

                    # Create a new Surface with the same size as the screenshot
                    grey_screenshot = pygame.Surface(screenshot.get_size())

                    # Iterate over each pixel in the screenshot
                    for x in range(screenshot.get_width()):
                        for y in range(screenshot.get_height()):
                            # Get the red, green, and blue values of the pixel
                            r, g, b, a = screenshot.get_at((x, y))

                            # Calculate the grey value
                            grey = int(0.299 * r + 0.587 * g + 0.114 * b)

                            # Set the pixel of the grey screenshot to the grey value
                            grey_screenshot.set_at((x, y), (grey, grey, grey, a))
                    pause_menu(screen, grey_screenshot)

        screen.blit(BG, (0, 0))

        hero.attack(mobs)
        hero.update(mobs, obstacles)

        for mob in mobs:
            mob.attack(hero, projectiles)
            mob.update()
            mob.draw(screen)

            if isinstance(mob, Boss):
                mob.attack(hero, projectiles)
                mob.update()

        projectiles.update()

        for projectile in projectiles:
            if hero.rect.colliderect(projectile.rect):
                hero.hurt(20)
                projectile.kill()

        for sprite in all_sprites:
            if sprite != hero:
                sprite.update()
        all_sprites.draw(screen)

        for mob in mobs:
            mob.draw(screen)

        for obstacle in obstacles:
            obstacle.draw(screen)

        for projectiled in projectiles:
            projectiled.draw(screen)

        if isinstance(hero.weapon, Gun):
            hero.weapon.update(screen, mobs)

        hero.draw(screen)

        screen.blit(hero.heart_image, (2, 2))

        if hero.shield > 0:
            screen.blit(hero.shield_image, (0, 50))

        pygame.display.update()
        fps.tick(120)


# Start the game
game(screen)
