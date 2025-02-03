from RoomView import RoomView
from RoomV2 import MapOfRoom
import pygame
import json

longueur = 1280
hauteur = 720

with open('data.json', 'r') as f:
    data = json.load(f)

map_of_room = MapOfRoom(data["__map_dir"], num_rooms=4)
screen = pygame.display.set_mode(longueur, hauteur)
pygame.display.set_caption("Example")

running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
    screen.fill((0, 0, 0))
    map_of_room.draw(screen)
    pygame.display.flip()
pygame.quit()
