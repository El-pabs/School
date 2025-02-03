import pygame
from sys import exit
from Menu_button import Button
from Hero import Hero
from Mob_spawn import add_mob, mobs, obstacles, add_boss, add_obstacle
from Weapons import *
from Obstacle import *
from Boss import *
from Mob import *
from Door_exit import ExitDoor

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

BG = pygame.image.load("assets/Graphics/background.png")
BG = pygame.transform.scale(BG, (width, height))

hero = Hero("Entitys/Mobs/Hero/hero.json")
all_sprites = pygame.sprite.Group()
all_sprites.add(hero)
projectiles = pygame.sprite.Group()

level = 1
old_level = level
etage = 1

def pause_menu(screen, paused):
    '''
    fonction qui affiche le menu pause
    les options sont: resume, save, quit
    '''
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
    pass

def draw_text(text, font, color, surface, x, y):
    '''
    fonction qui affiche du texte sur l'ecran
    '''
    textobj = font.render(text, True, color)
    textrect = textobj.get_rect()
    textrect.topleft = (x, y)
    surface.blit(textobj, textrect)

def main_menu(screen):
    '''
    fonction qui affiche le menu principal
    les options sont: new game, load game
    '''
    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                exit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_n:
                    return 'new'
                elif event.key == pygame.K_l:
                    return 'load'

        screen.fill((0, 0, 0))
        draw_text('MAIN MENU', font, (255, 255, 255), screen, width // 2 - 100, height // 2 - 200)
        draw_text('Press N for New Game', font, (255, 255, 255), screen, width // 2 - 150, height // 2 - 100)
        draw_text('Press L to Load Game', font, (255, 255, 255), screen, width // 2 - 150, height // 2)

        pygame.display.update()
        fps.tick(60)

def game(screen, pause=False):
    '''
    fonction qui gere le jeu
    '''
    global level, old_level, etage, mobs, obstacles, exit_door, BG
    boss_spawned = False
    exit_door = None
    current_room = "room1"
    next_room_position = None

    BG = pygame.image.load("assets/Graphics/background.png")
    BG = pygame.transform.scale(BG, (width, height))

    if hero.in_boss_room:
        if not boss_spawned and len(mobs) == 0:
            add_boss(hero)
            boss_spawned = True
    else:
        while len(mobs) < 5:
            add_mob(hero)
    while len(obstacles) < 2:
        add_obstacle(hero)

    def spawn_exit_door():
        positions = ["top", "bottom", "left", "right"]
        position = random.choice(positions)
        return ExitDoor(position)

    exit_door = spawn_exit_door()

    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                exit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_p:
                    pygame.image.save(screen, 'pause.png')
                    screenshot = pygame.image.load('pause.png')
                    grey_screenshot = pygame.Surface(screenshot.get_size())
                    for x in range(screenshot.get_width()):
                        for y in range(screenshot.get_height()):
                            r, g, b, a = screenshot.get_at((x, y))
                            grey = int(0.299 * r + 0.587 * g + 0.114 * b)
                            grey_screenshot.set_at((x, y), (grey, grey, grey, a))
                    pause_menu(screen, grey_screenshot)

        screen.blit(BG, (0, 0))

        if len(mobs) == 0:
            if hero.rect.colliderect(exit_door.rect):
                if exit_door.rect.center == (width // 2, 0):
                    next_room_position = "bottom"
                elif exit_door.rect.center == (width // 2, height):
                    next_room_position = "top"
                elif exit_door.rect.center == (0, height // 2):
                    next_room_position = "right"
                elif exit_door.rect.center == (width, height // 2):
                    next_room_position = "left"

                level += 1
                if level > old_level:
                    if etage == 1:
                        BG = pygame.image.load("assets/Graphics/background.png")
                        BG = pygame.transform.scale(BG, (width, height))
                    if level == 10:
                        add_boss(hero)
                        old_level = level
                        BG = pygame.image.load("assets/Graphics/boss_background.png")
                        BG = pygame.transform.scale(BG, (width, height))
                    else:
                        old_level = level
                        mobs = []
                        obstacles = []
                        for _ in range(5):
                            add_mob(hero)
                        for _ in range(2):
                            add_obstacle(hero)
                    exit_door = spawn_exit_door()

        for mob in mobs:
            mob.attack(hero, projectiles)
            mob.update()
            mob.draw(screen)
            if isinstance(mob, Boss):
                mob.attack(hero, projectiles)
                mob.update()

        hero.attack(mobs)
        hero.update(mobs, obstacles)
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

        if hero.weapon == gun:
            hero.weapon.update(screen, mobs)

        hero.draw(screen)
        screen.blit(hero.heart_image, (2, 2))

        if hero.shield > 0:
            screen.blit(hero.shield_image, (0, 50))

        exit_door.draw(screen)

        hero_status = hero.hurt(0)
        if hero_status == 'dead':
            pygame.mixer.music.stop()
            screen.fill((0, 0, 0))
            draw_text('GAME OVER', font, (255, 255, 255), screen, width / 2 - 100, height / 2 - 50 )
            draw_text('Press q to quit', font, (255, 255, 255), screen, width / 2 - 100, height / 2 )

            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    pygame.quit()
                    exit()
                if event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_q:
                        pygame.quit()
                        exit()

        pygame.display.update()
        fps.tick(120)



main_menu(screen)
