import json
import pygame
from Entity import Entity
from math import sqrt
from Weapons import *

pygame.init()
HAUTEUR, LARGEUR = 1280, 720


clock = pygame.time.Clock()
gun = Gun()
knife = Knife()
sword = Sword()

class Hero(Entity):
    '''
    classe qui permet de creer un hero
    '''
    def __init__(self, file_path):
        super().__init__(path=file_path)
        self.load_from_json(file_path)
        self.rage_end_time = 0
        self.normal_knife_range = 100
        self.normal_sword_range = 150
        self.knife_range = self.normal_knife_range
        self.sword_range = self.normal_sword_range
        self.__health = 200
        self.__max_health = 200
        self.health_bar_lenght = 400
        self.health_ratio = self.max_health / self.health_bar_lenght
        self.last_attack_time = pygame.time.get_ticks()
        self.weapon = gun
        self.shield = 0
        self.max_shield = 100
        self.shield_bar_length = 400
        self.shield_ratio = self.max_shield / self.shield_bar_length
        self.shield_state = False
        self.crosshair_image = pygame.image.load('assets/Graphics/crosshair.png').convert_alpha()
        self.crosshair_image = pygame.transform.scale(self.crosshair_image, (30, 30))
        self.crosshair_pos = [0, 0]
        self.heart_image = pygame.transform.scale((pygame.image.load("assets/Graphics/HUD/HUD_heart.png")), (40, 40))
        self.shield_image = pygame.transform.scale((pygame.image.load("assets/Graphics/HUD/HUD_shield.png")), (50, 50))
        self.in_boss_room = False
        self.mouvements = "perso"
    @property
    def health(self):
        return self.__health

    @health.setter
    def health(self, value):
        self.__health = value

    @property
    def max_health(self):
        return self.__max_health

    @max_health.setter
    def max_health(self, value):
        self.__max_health = value


    def load_from_json(self, file_path):
        '''
        Charge les donnees du hero depuis un fichier JSON
        '''
        try:
            with open(file_path, 'r') as file:
                hero_data = json.load(file)
                self.speed = hero_data.get("speed", 2.5)
                self.bonus = hero_data.get("bonus", [])
                self.shield = hero_data.get("shield", None)
                self.image_path = hero_data.get("image_path")
                if self.image_path:
                    self.load_entity_image(self.image_path)
                self.rect = self.image.get_rect()
                self.rect.center = (HAUTEUR // 2, LARGEUR // 2)
                self.name = hero_data.get("name", "Hero")
        except Exception as e:
            print(f"Error loading hero data from JSON: {e}")

    def attack(self, mobs):
        '''
        Methode qui permet au hero d'attaquer
        '''
        mouse_pressed = pygame.mouse.get_pressed()
        if mouse_pressed[0]:
            current_time = pygame.time.get_ticks()
            if current_time - self.last_attack_time >= 1000:
                if isinstance(self.weapon, Knife):
                    for mob in mobs:
                        dist = sqrt((self.rect.x - mob.rect.x) ** 2 + (self.rect.y - mob.rect.y) ** 2)
                        if dist <= self.knife_range:
                            mob.hurt(20, mobs)
                elif isinstance(self.weapon, Sword):
                    for mob in mobs:
                        dist = sqrt((self.rect.x - mob.rect.x) ** 2 + (self.rect.y - mob.rect.y) ** 2)
                        if dist <= self.sword_range:
                            mob.hurt(self.weapon.damage, mobs)
                elif isinstance(self.weapon, Gun):
                    self.weapon.fire(self, mobs)
                self.last_attack_time = current_time

    def hurt(self, damage):
        global hero_status
        '''
        Methode qui permet au hero de subir des degats
        '''
        if self.shield_state and self.shield > 0:
            self.shield -= damage
        else:
            self.shield_state = False
            self.health -= damage
            print(f"Hero health: {self.health}") if damage > 0 else None
            if self.health <= 0:
                return "dead"


    def basic_health(self):
        '''
        Methode qui permet d'afficher la barre de vie du hero
        '''
        from main import screen
        pygame.draw.rect(screen, (255, 0, 0), (45, 10, self.health/self.health_ratio, 25))
        pygame.draw.rect(screen, (0, 0, 0), (45 ,10, self.health_bar_lenght,25), 2)


    def basic_shield(self):
        '''
        Methode qui permet d'afficher la barre de bouclier du hero
        '''
        from main import screen
        pygame.draw.rect(screen, (0, 0, 255), (45, 60, self.shield/self.shield_ratio, 25))
        pygame.draw.rect(screen, (0, 0, 0), (45 ,60, self.shield_bar_length,25), 2)


    def update(self, mobs, obstacles):
        self.basic_health()
        if self.shield > 0:
            self.basic_shield()
        self.check_obstacle_collision(obstacles)
        self.check_rage_end()
        self.rotate_to_mouse()
        self.move()

    def rotate_to_mouse(self):
        '''
        Methode qui permet de faire tourner le reticule du gun
        en direction de la souris
        '''
        mouse_pos = pygame.mouse.get_pos()

        rel_x, rel_y = mouse_pos[0] - self.rect.centerx, mouse_pos[1] - self.rect.centery
        angle = (180 / math.pi) * math.atan2(rel_y, rel_x)

        crosshair_distance = 60
        self.crosshair_pos[0] = self.rect.centerx + crosshair_distance * math.cos(math.radians(angle))
        self.crosshair_pos[1] = self.rect.centery + crosshair_distance * math.sin(math.radians(angle))


    def check_obstacle_collision(self, obstacles):
        '''
        Methode qui permet de verifier si le hero entre en collision
        Avec un obstacle et applique l'effet de l'obstacle
        '''
        for obstacle in obstacles:
            if self.rect.colliderect(obstacle.rect):
                obstacle.apply_effect(self)
                obstacles.remove(obstacle)

    def check_rage_end(self):
        '''
        Methode qui permet de verifier si la rage du hero est termin
        '''
        if pygame.time.get_ticks() > self.rage_end_time:
            self.knife_range = self.normal_knife_range
            self.sword_range = self.normal_sword_range

    def draw(self, screen):
        if isinstance(self.weapon, Gun):
            screen.blit(self.crosshair_image, (self.crosshair_pos[0], self.crosshair_pos[1]))

    def move(self):
        key = pygame.key.get_pressed()
        if key[pygame.K_LEFT] or key[pygame.K_q]:
            self.rect.x -= self.speed
        if key[pygame.K_RIGHT] or key[pygame.K_d]:
            self.rect.x += self.speed
        if key[pygame.K_UP] or key[pygame.K_z]:
            self.rect.y -= self.speed
        if key[pygame.K_DOWN] or key[pygame.K_s]:
            self.rect.y += self.speed
        if self.rect.x < 50:
            self.rect.x = 50
        if self.rect.y < 0:
            self.rect.y = 0
        if self.rect.x > HAUTEUR - self.rect.width - 50:
            self.rect.x = HAUTEUR - self.rect.width -50
        if self.rect.y > LARGEUR - self.rect.height - 50:
            self.rect.y = LARGEUR - self.rect.height - 50
