import pygame
import math

class Weapon:
    def __init__(self, damage, cooldown):
        self.damage = damage
        self.cooldown = cooldown
        self.last_fire_time = pygame.time.get_ticks()

    def can_fire(self):
        current_time = pygame.time.get_ticks()
        return current_time - self.last_fire_time >= self.cooldown

    def fire(self, hero, mobs):
        pass

class Knife(Weapon):
    def __init__(self):
        super().__init__(damage=20, cooldown=1000)  # Knife deals 20 damage and has a cooldown of 1 second

class Sword(Weapon):
    def __init__(self):
        super().__init__(damage=30, cooldown=1500)  # Sword deals 30 damage and has a cooldown of 1.5 seconds

class Bullet:
    def __init__(self, start_pos, target_pos, damage):
        self.pos = list(start_pos)
        self.target = list(target_pos)
        self.speed = 10
        self.damage = damage
        direction = [self.target[0] - self.pos[0], self.target[1] - self.pos[1]]
        length = math.sqrt(direction[0]**2 + direction[1]**2)
        self.direction = [direction[0]/length, direction[1]/length]
        self.image = pygame.image.load('assets/Graphics/Projectiles/bullet.png')  # Load the bullet image
        self.image = pygame.transform.scale(self.image, (30, 30))  # Scale the image

    def update(self):
        self.pos[0] += self.direction[0] * self.speed
        self.pos[1] += self.direction[1] * self.speed

    def intersects(self, mob):
        return mob.rect.collidepoint(self.pos[0], self.pos[1])

    def draw(self, screen):
        screen.blit(self.image, (self.pos[0], self.pos[1]))  # Draw the bullet image on the screen

class Gun(Weapon):
    def __init__(self):
        super().__init__(damage=34, cooldown=500)  # Gun deals 34 damage and has a cooldown of 0,5 second
        self.bullets = []

    def fire(self, hero, mobs):
        if self.can_fire():
            mouse_pos = pygame.mouse.get_pos()
            bullet = Bullet(hero.rect.center, mouse_pos, self.damage)
            self.bullets.append(bullet)
            self.last_fire_time = pygame.time.get_ticks()

    def update(self, screen, mobs):  # Add screen as a parameter
        for bullet in self.bullets:
            bullet.update()
            bullet.draw(screen)  # Draw the bullet on the screen
            for mob in mobs:
                if bullet.intersects(mob):
                    mob.hurt(self.damage, mobs)
                    self.bullets.remove(bullet)
                    break