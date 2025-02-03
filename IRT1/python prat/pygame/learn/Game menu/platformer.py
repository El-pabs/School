import random
import time
import pygame
from sys import exit
import pygame.math
from random import randint, randrange

pygame.init()
vec = pygame.math.Vector2 # 2 for two dimensional

# constantes
WIDTH = 400
HEIGHT = 450
FPS = 60
ACC = 0.5
FRIC = -0.12

frame = pygame.time.Clock()

# créer la fenêtre
screen = pygame.display.set_mode((WIDTH,HEIGHT))
pygame.display.set_caption("Platformer")



#créer le joueur
class Player(pygame.sprite.Sprite):
    def __init__(self):
        super().__init__()

        # créer le sprite du joueur
        self.surf = pygame.Surface((30,30))
        self.surf.fill((128,255,40))
        self.rect = self.surf.get_rect()

        # position et vitesse du joueur
        self.pos = vec((10,285))
        self.vel = vec(0,0)
        self.acc = vec(0,0)
        self.jumping = False

        # score
        self.score = 0

    def move(self):

        self.acc = vec(0,0.5)
        keys = pygame.key.get_pressed()

        if keys[pygame.K_q]:
            self.acc.x = -ACC
        if keys[pygame.K_d]:
            self.acc.x = ACC

        # équations de mouvement
        self.acc.x += self.vel.x * FRIC
        self.vel += self.acc
        self.pos += self.vel + 0.5 * self.acc

        # teleportation de gauche à droite et vice versa
        if self.pos.x > WIDTH:
            self.pos.x = 0
        if self.pos.x < 0:
            self.pos.x = WIDTH

        self.rect.midbottom = self.pos

    def jump(self):
        hits = pygame.sprite.spritecollide(player, platforms, False)
        if hits and not self.jumping:
            self.jumping = True
            self.vel.y = -15

    def cancel_jump(self):
        if self.jumping:
            if self.vel.y < -3:
                self.vel.y = -3

    def update(self):
        hits = pygame.sprite.spritecollide(player, platforms, False)
        if player.vel.y > 0:
            if hits:
                if self.pos.y < hits[0].rect.bottom:
                    if hits[0].point:
                        hits[0].point = False
                        self.score += 1
                    self.pos.y = hits[0].rect.top + 1
                    self.vel.y = 0
                    self.jumping = False



class Platform(pygame.sprite.Sprite):
    def __init__(self):
        super().__init__()
        self.surf = pygame.Surface((randint(50,100),12))
        self.surf.fill((0,255,0))
        self.rect = self.surf.get_rect(center = (randint(0,WIDTH-10),randint(0,HEIGHT-10)))

        # pour vérifier si le joueur a déjà touché la plateforme
        self.point = True
        self.moving = True
        self.speed = random.randint(-1,1)

    def move(self):
        if self.moving == True:
            self.rect.move_ip(self.speed, 0)
            if self.speed > 0 and self.rect.left > WIDTH:
                self.rect.right = 0
            if self.speed < 0 and self.rect.right < 0:
                self.rect.left = WIDTH

class ShrinkingPlatform(Platform):
    def __init__(self):
        super().__init__()
        self.surf.fill((255, 0, 0))
        self.shrinking = False
        print("ShrinkingPlatform created")

    def update(self):
        # Check if the bottom of the player is within a certain range of the top of the platform
        if self.rect.top <= player.rect.bottom <= self.rect.top + 2:
            self.shrinking = True
            print("Shrinking")

        if self.shrinking:
            if self.surf.get_width() > player.surf.get_width():
                # Decrease the width by a smaller value
                new_width = self.surf.get_width() - 0.5
                self.surf = pygame.transform.scale(self.surf, (int(new_width), self.surf.get_height()))
                self.rect = self.surf.get_rect(center = (self.rect.centerx, self.rect.centery))
            else:
                self.kill()



def check(platform, groupies):
    if pygame.sprite.spritecollideany(platform,groupies):
        return True
    else:
        for entity in groupies:
            if entity == platform:
                continue
            if (abs(platform.rect.top - entity.rect.bottom) < 40) and (abs(platform.rect.bottom - entity.rect.top) < 40):
                return True
        C = False


# créer une fonction pour générer des plateformes
def plat_gen():
    MAX_ATTEMPTS = 1000  # Maximum number of attempts to create a new platform

    while len(platforms) < 7:
        C = True
        attempts = 0  # Number of attempts to create a new platform

        while C:
            if attempts >= MAX_ATTEMPTS:
                print("Error: Maximum number of attempts to create a new platform reached")
                return

            # Generate a random number between 0 and 1
            rand_num = random.random()
            # If the number is less than or equal to 0.8, generate a Platform instance
            if rand_num <= 0.8:
                p = Platform()
                color = (0, 255, 0)  # Green
            # If the number is greater than 0.8, generate a ShrinkingPlatform instance
            else:
                p = ShrinkingPlatform()
                color = (255, 0, 0)  # Red

            # Generate a random width and height for the platform
            platform_width = random.randrange(50, 100)
            platform_height = 10

            p.surf = pygame.Surface((platform_width, platform_height))  # Set the surface size to the random width and height
            p.surf.fill(color)  # Set the color of the surface
            p.rect = p.surf.get_rect(center = (random.randrange(0, WIDTH - platform_width), random.randrange(-50, 0)))
            C = check(p, platforms)
            attempts += 1

        platforms.add(p)
        all_sprites.add(p)

def reset_game_platformer():
    global all_sprites, platforms, player
    all_sprites.empty()
    platforms.empty()

    player = Player()
    PT1 = Platform()
    PT1.point = False
    PT1.moving = False
    PT1.surf = pygame.Surface((WIDTH, 20))
    PT1.surf.fill((255, 0, 0))
    PT1.rect = PT1.surf.get_rect(center=(WIDTH / 2, HEIGHT - 10))

    all_sprites.add(PT1)
    all_sprites.add(player)
    platforms.add(PT1)

    for x in range(randint(5, 6)):
        pl = Platform()
        C = True
        while C:
            pl = Platform()
            C = check(pl, platforms)
        platforms.add(pl)
        all_sprites.add(pl)


# créer le joueur
player = Player()
PT1 = Platform()
PT1.point = False # pour éviter de compter le score deux fois
PT1.moving = False # pour éviter que la plateforme ne bouge

PT1.surf = pygame.Surface((WIDTH,20))
PT1.surf.fill((255,0,0))
PT1.rect = PT1.surf.get_rect(center = (WIDTH/2,HEIGHT-10))

# ajouter les sprites à un groupe
all_sprites = pygame.sprite.Group()
all_sprites.add(PT1)
all_sprites.add(player)
platforms = pygame.sprite.Group()
platforms.add(PT1)

# ajouter des plateformes aléatoires au groupe de plateformes et de sprites all_sprites et platforms respectivement
for x in range(randint(5,6)):
    pl = Platform()
    C = True
    while C:
        pl = Platform()
        C = check(pl, platforms)
    platforms.add(pl)
    all_sprites.add(pl)

def Platform_play():
    while True:
        player.update()
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                exit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_SPACE:
                    player.jump()
            if event.type == pygame.KEYUP:
                if event.key == pygame.K_SPACE:
                    player.cancel_jump()

        if player.rect.top <= HEIGHT /3:
            player.pos.y += abs(player.vel.y)
            for plat in platforms:
                plat.rect.y += abs(player.vel.y)
                if plat.rect.top >= HEIGHT:
                    plat.kill()

        if player.rect.top > HEIGHT:
            for entity in all_sprites:
                entity.kill()

                return f"Score réalisé {player.score}"

        plat_gen()

        # dessiner la fenêtre
        screen.fill((0,0,0))
        player.move()

        test_font = pygame.font.Font(None, 50)
        score = test_font.render(str(player.score), True, (255,255,255))
        screen.blit(score, (WIDTH/2, 10))

        # dessiner les sprites
        for entity in all_sprites:
            screen.blit(entity.surf, entity.rect)

        for plat in platforms:
            plat.move()

        all_sprites.update()


        pygame.display.update()
        frame.tick(FPS)