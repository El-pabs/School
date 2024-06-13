import pygame

pygame.init()

class Projectile(pygame.sprite.Sprite):
    '''
    Classe projectile
    '''
    def __init__(self, start_pos, target_pos, image):
        super().__init__()
        image = pygame.image.load(image).convert_alpha()
        self.__image = pygame.transform.scale(image, (50, 50))
        self.__rect = self.__image.get_rect(center=start_pos)
        self.__direction = pygame.Vector2(target_pos) - self.__rect.center
        self.__direction.normalize_ip()
        self.__speed = 10

    def update(self):
        '''
        actualise la position du projectile
        '''
        self.rect.center += self.direction * self.speed
        if not pygame.display.get_surface().get_rect().colliderect(self.rect):
            self.kill()

    def draw(self, surface):
        surface.blit(self.image, self.rect)

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