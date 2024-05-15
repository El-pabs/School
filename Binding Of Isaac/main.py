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


def draw_text(text, font, color, surface, x, y):
    textobj = font.render(text, True, color)
    textrect = textobj.get_rect()
    textrect.topleft = (x, y)
    surface.blit(textobj, textrect)


def pause_menu(screen):
    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                exit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_r:  # Resume
                    return
                elif event.key == pygame.K_s:  # Save
                    save_game()
                elif event.key == pygame.K_q:  # Quit
                    pygame.quit()
                    exit()

        screen.fill((0, 0, 0))
        draw_text('PAUSE MENU', font, (255, 255, 255), screen, width // 2 - 100, height // 2 - 200)
        draw_text('Press R to Resume', font, (255, 255, 255), screen, width // 2 - 150, height // 2 - 100)
        draw_text('Press S to Save', font, (255, 255, 255), screen, width // 2 - 150, height // 2)
        draw_text('Press Q to Quit', font, (255, 255, 255), screen, width // 2 - 150, height // 2 + 100)

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
                    pause_menu(screen)

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
