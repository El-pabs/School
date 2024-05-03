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
height = 450
FPS = 60
ACC = 0.5
FRIC = -0.12

frame = pygame.time.Clock()

# créer la fenêtre
screen = pygame.display.set_mode((WIDTH,height))
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
        self.rect = self.surf.get_rect(center = (randint(0,WIDTH-10),randint(0,height-10)))

        # pour vérifier si le joueur a déjà touché la plateforme
        self.point = True
        self.moving = True
        self.speed = random.randint(-1,1)

    def move(self):
        if self.moving == True:
            self.rect.move_ip(self.speed,0)
            if self.speed>0 and self.rect.left > WIDTH:
                self.rect.right = 0
            if self.speed<0 and self.rect.right < 0:
                self.rect.left = WIDTH


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
    while len(platforms) < 7:
        width = randrange(50,100)
        C = True
        while C:
            p = Platform()
            p.rect.center = (random.randrange(0,WIDTH-width),
                             random.randrange(-50,0))
            C = check(p, platforms)

        platforms.add(p)
        all_sprites.add(p)


# créer le joueur
player = Player()
PT1 = Platform()
PT1.point = False # pour éviter de compter le score deux fois
PT1.moving = False # pour éviter que la plateforme ne bouge

PT1.surf = pygame.Surface((WIDTH,20))
PT1.surf.fill((255,0,0))
PT1.rect = PT1.surf.get_rect(center = (WIDTH/2,height-10))

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

    if player.rect.top <= height /3:
        player.pos.y += abs(player.vel.y)
        for plat in platforms:
            plat.rect.y += abs(player.vel.y)
            if plat.rect.top >= height:
                plat.kill()


    if player.rect.top > height:
        for entity in all_sprites:
            entity.kill()
            time.sleep(1)
            screen.fill((255,0,0))
            pygame.display.update()
            exit()

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

    pygame.display.update()
    frame.tick(FPS)