import json
import pygame
import random
from Entity import Entity


class Fireball(pygame.sprite.Sprite):
    '''
    Classe Fireball : Classe représentant les boules de feu lancées par le boss
    '''
    def __init__(self, start_pos, target_pos):
        super().__init__()
        image = pygame.image.load('assets/Graphics/Projectiles/fireball.png')
        self.__image = pygame.transform.scale(image, (50, 50))
        self.__rect = self.__image.get_rect(center=start_pos)
        self.__direction = pygame.Vector2(target_pos) - self.__rect.center
        self.__direction.normalize_ip()
        self.__speed = 8

    def update(self):
        self.__rect.center += self.__direction * self.__speed
        if not pygame.display.get_surface().get_rect().colliderect(self.__rect):
            self.kill()

    def draw(self, surface):
        surface.blit(self.__image, self.__rect)

    @property
    def image(self):
        return self.__image

    @image.setter
    def image(self, value):
        self.__image = value

    @property
    def rect(self):
        return self.__rect

    @rect.setter
    def rect(self, value):
        self.__rect = value

    @property
    def direction(self):
        return self.__direction

    @direction.setter
    def direction(self, value):
        self.__direction = value

    @property
    def speed(self):
        return self.__speed

    @speed.setter
    def speed(self, value):
        self.__speed = value


class FireWall(pygame.sprite.Sprite):
    '''
    Classe FireWall : Classe représentant le mur de feu lancé par le boss
    '''
    def __init__(self, start_pos, target_pos):
        super().__init__()
        image = pygame.image.load('assets/Graphics/Projectiles/firewall.png')
        self.__image = pygame.transform.scale(image, (100, 150))
        self.__rect = self.__image.get_rect(center=start_pos)
        self.__direction = pygame.Vector2(target_pos) - self.__rect.center
        self.__direction.normalize_ip()
        self.__speed = 7

    def update(self):
        self.__rect.center += self.__direction * self.__speed
        if not pygame.display.get_surface().get_rect().colliderect(self.__rect):
            self.kill()

    def draw(self, surface):
        surface.blit(self.__image, self.__rect)

    @property
    def image(self):
        return self.__image

    @image.setter
    def image(self, value):
        self.__image = value

    @property
    def rect(self):
        return self.__rect

    @rect.setter
    def rect(self, value):
        self.__rect = value

    @property
    def direction(self):
        return self.__direction

    @direction.setter
    def direction(self, value):
        self.__direction = value

    @property
    def speed(self):
        return self.__speed

    @speed.setter
    def speed(self, value):
        self.__speed = value


class Boss(Entity):
    '''
    Classe Boss : Classe représentant le boss du jeu
    '''
    def __init__(self, image, x, y, hero, path="Entitys/Mobs/Boss/boss.json"):
        super().__init__(path)
        self.__fury_mode = False
        self.__resistance = 0
        self.__level = 150
        self.load_boss_data(path)
        self.__image = image
        self.__rect = self.__image.get_rect(topleft=(x, y))
        self.__last_attack_time = pygame.time.get_ticks()
        self.__x = x
        self.__y = y
        self.__target = hero
        self.__Id = 4
        self.__health = 1000
        self.__last_spawn_time = pygame.time.get_ticks()
        self.__movement_timer = 0
        self.__change_movement_time = 5000
        self.die_song = pygame.mixer.Sound('assets/Sound/nein.mp3')

    def update(self):
        self.spawn_obstacles()
        super().update()

    def load_boss_data(self, path):
        '''
        Méthode pour charger les données du boss depuis un fichier JSON
        '''
        try:
            with open(path, 'r') as file:
                boss_data = json.load(file)
                self.fury_mode = boss_data.get("fury_mode", self.fury_mode)
                self.resistance = boss_data.get("resistance", self.resistance)
                self.level = boss_data.get("level", self.level)
                self.Id = boss_data.get("Id", self.Id)
                self.health = boss_data.get("health", self.health)
        except FileNotFoundError:
            print(f"Erreur : fichier JSON introuvable - {path}")
        except json.JSONDecodeError:
            print(f"Erreur : fichier JSON malformé - {path}")
        except Exception as e:
            print(f"Erreur lors du chargement des données depuis le fichier JSON: {e}")

    def draw(self, screen):
        screen.blit(self.__image, self.__rect)

    def attack(self, target, projectiles=None):
        '''
        Méthode pour faire attaquer le boss
        '''
        if self.Id == 4:
            from main import projectiles
            current_time = pygame.time.get_ticks()
            if current_time - self.last_attack_time >= (500 if self.fury_mode else 1500):
                attack_type = random.choice(['fireball', 'firewall'])
                self.die_song.play()
                if attack_type == 'fireball':
                    fireball = Fireball(self.rect.center, target.rect.center)
                    projectiles.add(fireball)
                elif attack_type == 'firewall':
                    firewall = FireWall(self.rect.center, target.rect.center)
                    projectiles.add(firewall)
                self.last_attack_time = current_time

    def hurt(self, damage, mobs):
        '''
        Méthode pour infliger des dégâts au boss
        '''
        self.health -= damage
        print(self.health)
        if self.health in range(0, 500):
            self.fury_mode = True

        if self.health <= 0:
            '''
            Si la santé du boss atteint 0, on va le tuer
            On va aussi incrémenter l'étage et remettre le niveau à 1
            '''
            from main import etage, level
            mobs.remove(self)
            self.kill()
            global etage, level
            etage += 1
            level = 1

    def spawn_obstacles(self):
        '''
        Méthode pour faire apparaitre des obstacles pendant le combat de boss
        '''
        if self.Id == 4:
            from Mob_spawn import add_obstacle
            from main import hero
            count_time = pygame.time.get_ticks()
            if count_time - self.last_spawn_time >= 10000:
                print('Obstacle spawned by the boss')
                add_obstacle(hero)
                self.last_spawn_time = count_time

    @property
    def fury_mode(self):
        return self.__fury_mode

    @fury_mode.setter
    def fury_mode(self, value):
        self.__fury_mode = value

    @property
    def resistance(self):
        return self.__resistance

    @resistance.setter
    def resistance(self, value):
        self.__resistance = value

    @property
    def level(self):
        return self.__level

    @level.setter
    def level(self, value):
        self.__level = value

    @property
    def image(self):
        return self.__image

    @image.setter
    def image(self, value):
        self.__image = value

    @property
    def rect(self):
        return self.__rect

    @rect.setter
    def rect(self, value):
        self.__rect = value

    @property
    def last_attack_time(self):
        return self.__last_attack_time

    @last_attack_time.setter
    def last_attack_time(self, value):
        self.__last_attack_time = value

    @property
    def x(self):
        return self.__x

    @x.setter
    def x(self, value):
        self.__x = value

    @property
    def y(self):
        return self.__y

    @y.setter
    def y(self, value):
        self.__y = value

    @property
    def target(self):
        return self.__target

    @target.setter
    def target(self, value):
        self.__target = value

    @property
    def Id(self):
        return self.__Id

    @Id.setter
    def Id(self, value):
        self.__Id = value

    @property
    def health(self):
        return self.__health

    @health.setter
    def health(self, value):
        self.__health = value

    @property
    def last_spawn_time(self):
        return self.__last_spawn_time

    @last_spawn_time.setter
    def last_spawn_time(self, value):
        self.__last_spawn_time = value

    @property
    def movement_timer(self):
        return self.__movement_timer

    @movement_timer.setter
    def movement_timer(self, value):
        self.__movement_timer = value

    @property
    def change_movement_time(self):
        return self.__change_movement_time

    @change_movement_time.setter
    def change_movement_time(self, value):
        self.__change_movement_time = value

    @property
    def die_song(self):
        return self.__die_song

    @die_song.setter
    def die_song(self, value):
        self.__die_song = value
