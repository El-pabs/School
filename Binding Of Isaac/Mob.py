import json
import pygame
from Boss import Boss
from math import sqrt
from Hero import *
from Projectile import Projectile


HAUTEUR, LARGEUR = 800, 800

# Initialisation de Pygame
pygame.init()
screen = pygame.display.set_mode((HAUTEUR, LARGEUR))
clock = pygame.time.Clock()


class Mob(Boss):
    def __init__(self, image, x, y, target,Id=2 ,path='Entitys/Mobs/Normal_Mobs/RandomMob.json'):
        super().__init__(image, x, y, target, path)
        self.health = 100
        self.level = 50
        self.Id = Id
        self.load_mob_data(path)
        self.x = x
        self.y = y
        self.target = target
        self.image = image
        self.rect = self.image.get_rect(topleft=(x, y))
        self.last_attack_time = pygame.time.get_ticks()  # Store the time of the last attack

    def load_mob_data(self, path):
        try:
            with open(path, 'r') as file:
                mob_data = json.load(file)
                self.health = mob_data.get("health", self.health)
                self.level = mob_data.get("level", self.level)
        except FileNotFoundError:
            print(f"Erreur : fichier JSON introuvable - {path}")
        except json.JSONDecodeError:
            print(f"Erreur : fichier JSON malformé - {path}")
        except Exception as e:
            print(f"Erreur lors du chargement des données depuis le fichier JSON: {e}")

    def hurt(self, damage, mobs):
        self.health -= damage
        print(f"Mob health: {self.health}")
        if self.health <= 0:
            self.kill(mobs)  # Remove the mob if its health reaches 0

    def shoot(self):
        from main import projectiles
        current_time = pygame.time.get_ticks()
        if current_time - self.last_attack_time >= 3000:
            # Create a new projectile
            projectile = Projectile(self.rect.center, self.target.rect.center)
            # Add the projectile to the projectiles group
            projectiles.add(projectile)
            self.last_attack_time = current_time

    def kill(self, mobs):
        if self in mobs:
            mobs.remove(self)
        super().kill()  # Call the kill method of the superclass

    def update(self):
        if self.Id == 2:
            self.shoot()
        if self.Id == 1:
            if self.rect.colliderect(self.target.rect):
                current_time = pygame.time.get_ticks()
                if current_time - self.last_attack_time >= 1000:
                    self.target.hurt(10)
                    self.last_attack_time = current_time

        super().update()

    def intersects(self, other):
        return self.rect.colliderect(other.rect)

    def draw(self, surface):
        surface.blit(self.image, self.rect)

    def show_informations(self):
        super().show_informations()
        if self.show_player_information:
            info_surface = pygame.Surface((200, 50))
            info_surface.fill((0, 0, 0))
            info = [
                f"Résistance: {self.resistance}",
                f"Deplacement: {self.deplacement}",
                f"Level: {self.level}"
            ]
            for i, text in enumerate(info):
                info_surface.blit(pygame.font.SysFont(None, 20).render(text, True, (255, 255, 255)), (10, i * 20))
            screen.blit(info_surface, (self.rect.x, self.rect.y - 50))
            pygame.display.flip()

