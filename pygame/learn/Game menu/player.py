import pygame


class Player(pygame.sprite.Sprite):
    def __init__(self):
        super(Player, self).__init__()
        self.anim01 = pygame.image.load("img/livo (1).png").convert_alpha()
        self.anim01 = pygame.transform.scale(self.anim01, (70,70))

        self.anim02 = pygame.image.load("img/livo (2).png").convert_alpha()
        self.anim02 = pygame.transform.scale(self.anim02, (70, 70))


        self.animation = [self.anim01, self.anim02]

        self.indexAnim = 0

        self.surf = self.animation[self.indexAnim]

        self.rect = pygame.Rect(0, 0, 60, 60)

    def playerAnimation(self):
        self.indexAnim += 1

        if self.indexAnim > 1:
            self.indexAnim = 0

        self.surf = self.animation[self.indexAnim]

    def update(self, pressed_keys, WIDTH, HEIGHT):

    # Permet de déplacer le joueur avec les flèches du clavier
        if pressed_keys[pygame.K_UP]:
            self.rect.move_ip(0, -10)
        if pressed_keys[pygame.K_DOWN]:
            self.rect.move_ip(0, 10)
        if pressed_keys[pygame.K_LEFT]:
            self.rect.move_ip(-10, 0)
        if pressed_keys[pygame.K_RIGHT]:
            self.rect.move_ip(10, 0)

    # Garde le joueur à l’écran
        if self.rect.left < 0:
            self.rect.left = 0
        if self.rect.right > WIDTH:
            self.rect.right = WIDTH
        if self.rect.top <= 0:
            self.rect.top = 0
        if self.rect.bottom >= HEIGHT:
            self.rect.bottom = HEIGHT
