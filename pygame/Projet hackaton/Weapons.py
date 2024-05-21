import pygame
import math

screen = pygame.display.set_mode((1280, 720))

class Weapon:
    '''
    Cette classe représente une arme dans le jeu.
    '''
    def __init__(self, damage, cooldown):
        self.__damage = damage
        self.__cooldown = cooldown
        self.__last_fire_time = pygame.time.get_ticks()

    def can_fire(self):
        '''
        Cette méthode permet de savoir si l'arme peut tirer.
        '''
        current_time = pygame.time.get_ticks()
        return current_time - self.__last_fire_time >= self.__cooldown

    def fire(self, hero, mobs):
        pass

    def draw(self, screen, x, y , image_path):
        image = pygame.image.load(image_path)
        image = pygame.transform.scale(image, (30, 30))
        screen.blit(image, (x, y))

    @property
    def damage(self):
        return self.__damage

    @damage.setter
    def damage(self, value):
        self.__damage = value

    @property
    def cooldown(self):
        return self.__cooldown

    @cooldown.setter
    def cooldown(self, value):
        self.__cooldown = value

    @property
    def last_fire_time(self):
        return self.__last_fire_time

    @last_fire_time.setter
    def last_fire_time(self, value):
        self.__last_fire_time = value


class Knife(Weapon):
    '''
    Cette classe représente un couteau dans le jeu.
    '''
    def __init__(self):
        super().__init__(damage=20, cooldown=1000)


class Sword(Weapon):
    '''
    Cette classe représente une épée dans le jeu.
    '''
    def __init__(self):
        super().__init__(damage=30, cooldown=1500)


class Bullet:
    '''
    Cette classe représente une balle dans le jeu.
    '''
    def __init__(self, start_pos, target_pos, damage):
        self.__pos = list(start_pos)
        self.__target = list(target_pos)
        self.__speed = 10
        self.__damage = damage
        direction = [self.__target[0] - self.__pos[0], self.__target[1] - self.__pos[1]]
        length = math.sqrt(direction[0]**2 + direction[1]**2)
        self.__direction = [direction[0] / length, direction[1] / length]
        self.__image = pygame.image.load('assets/Graphics/Projectiles/bullet.png')
        self.__image = pygame.transform.scale(self.__image, (30, 30))

    def update(self):
        '''
        Cette méthode permet de mettre à jour la position de la balle.
        '''
        self.__pos[0] += self.__direction[0] * self.__speed
        self.__pos[1] += self.__direction[1] * self.__speed

    def intersects(self, mob):
        '''
        Cette méthode permet de savoir si la balle touche un monstre.
        '''
        return mob.rect.collidepoint(self.__pos[0], self.__pos[1])

    def draw(self, screen):
        screen.blit(self.__image, (self.__pos[0], self.__pos[1]))

    @property
    def pos(self):
        return self.__pos

    @pos.setter
    def pos(self, value):
        self.__pos = value

    @property
    def target(self):
        return self.__target

    @target.setter
    def target(self, value):
        self.__target = value

    @property
    def speed(self):
        return self.__speed

    @speed.setter
    def speed(self, value):
        self.__speed = value

    @property
    def damage(self):
        return self.__damage

    @damage.setter
    def damage(self, value):
        self.__damage = value

    @property
    def direction(self):
        return self.__direction

    @direction.setter
    def direction(self, value):
        self.__direction = value

    @property
    def image(self):
        return self.__image

    @image.setter
    def image(self, value):
        self.__image = value


class Gun(Weapon):
    '''
    Cette classe représente un pistolet dans le jeu.
    '''
    def __init__(self):
        super().__init__(damage=34, cooldown=500)
        self.__bullets = []

    def fire(self, hero, mobs):
        '''
        Cette méthode permet de faire tirer le pistolet.
        '''
        if self.can_fire():
            mouse_pos = pygame.mouse.get_pos()
            bullet = Bullet(hero.rect.center, mouse_pos, self.damage)
            self.__bullets.append(bullet)
            self.last_fire_time = pygame.time.get_ticks()

    def update(self, screen, mobs):
        '''
        Cette méthode permet de mettre à jour les balles du pistolet.
        En particulier, elle permet de vérifier si une balle touche un monstre.
        '''
        for bullet in self.__bullets:
            bullet.update()
            bullet.draw(screen)
            for mob in mobs:
                if bullet.intersects(mob):
                    mob.hurt(self.damage, mobs)
                    self.__bullets.remove(bullet)
                    break

    @property
    def bullets(self):
        return self.__bullets

    @bullets.setter
    def bullets(self, value):
        self.__bullets = value
