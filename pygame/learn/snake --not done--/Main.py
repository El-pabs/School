import pygame
from pygame.locals import *
pygame.init()

height = 600
width = 600
black = (0,0,0)
blue = (0,0,255)
bg = (255, 200,150)
red = (255, 0 ,0)
body_inner = (50,175,25)
body_outer = (100,100,200)

screen = pygame.display.set_mode((height, width))
pygame.display.set_caption("Snake")

#game variables
cell_size = 10
direction = 1 #1 is up 2 right, 3 down , 4 left

#create snake
snake_pos =[[int(width / 2), int(height / 2)]]
snake_pos.append([int(width / 2), int(height / 2) + cell_size])
snake_pos.append([int(width / 2), int(height / 2) + cell_size * 2])
snake_pos.append([int(width / 2), int(height / 2) + cell_size * 3])


def draw_screen():
    screen.fill(bg)

running = True
while running:

    draw_screen()

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_UP and direction != 3:
                direction = 1
            if event.key == pygame.K_RIGHT and direction != 4:
                direction = 2
            if event.key == pygame.K_DOWN and direction != 1:
                direction = 3
            if event.key == pygame.K_LEFT and direction != 2:
                direction = 4

    snake_pos = snake_pos[-1:] + snake_pos[:-1]
    #up
    if direction == 1:
        pass

    #draw snake
    head = 1
    for x in snake_pos:
        if head == 0:
            pygame.draw.rect(screen, blue, (x[0], x[1], cell_size, cell_size))
            pygame.draw.rect(screen, body_inner, (x[0] + 1 ,x[1] + 1, cell_size - 2, cell_size - 2))
        if head == 1:
            pygame.draw.rect(screen, body_outer, (x[0], x[1], cell_size, cell_size))
            pygame.draw.rect(screen, red, (x[0] + 1 ,x[1] + 1, cell_size - 2, cell_size - 2))
            head = 0




    pygame.display.update()






pygame.quit()
