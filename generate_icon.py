from PIL import Image, ImageDraw, ImageFont
import os

def create_app_icon():
    # Crear imagen de 512x512
    size = 512
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Fondo con gradiente simulado
    for y in range(size):
        for x in range(size):
            # Gradiente de azul
            ratio_x = x / size
            ratio_y = y / size
            
            # Colores del gradiente
            r1, g1, b1 = 60, 47, 207  # #3C2FCF
            r2, g2, b2 = 74, 58, 255  # #4A3AFF
            
            r = int(r1 + (r2 - r1) * (ratio_x + ratio_y) / 2)
            g = int(g1 + (g2 - g1) * (ratio_x + ratio_y) / 2)
            b = int(b1 + (b2 - b1) * (ratio_x + ratio_y) / 2)
            
            img.putpixel((x, y), (r, g, b, 255))
    
    # Crear máscara redondeada
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, size, size], radius=128, fill=255)
    
    # Aplicar máscara
    img.putalpha(mask)
    
    # Dibujar círculo de fondo decorativo
    circle_size = 360
    circle_pos = (size//2 - circle_size//2, size//2 - circle_size//2)
    draw.ellipse([circle_pos[0], circle_pos[1], 
                  circle_pos[0] + circle_size, circle_pos[1] + circle_size], 
                 fill=(255, 255, 255, 25))
    
    # Dibujar alcancía estilizada
    center_x, center_y = size//2, size//2
    
    # Cuerpo principal (elipse)
    body_width, body_height = 240, 160
    draw.ellipse([center_x - body_width//2, center_y - body_height//2 + 40,
                  center_x + body_width//2, center_y + body_height//2 + 40], 
                 fill=(255, 255, 255, 255))
    
    # Cabeza
    head_width, head_height = 120, 100
    draw.ellipse([center_x - head_width//2 - 40, center_y - head_height//2 - 80,
                  center_x + head_width//2 - 40, center_y + head_height//2 - 80], 
                 fill=(255, 255, 255, 255))
    
    # Oreja
    ear_width, ear_height = 30, 50
    draw.ellipse([center_x - 120, center_y - 140,
                  center_x - 120 + ear_width, center_y - 140 + ear_height], 
                 fill=(255, 255, 255, 255))
    
    # Ojo
    draw.ellipse([center_x - 80, center_y - 100,
                  center_x - 64, center_y - 84], 
                 fill=(60, 47, 207, 255))
    
    # Hocico
    draw.ellipse([center_x - 150, center_y - 70,
                  center_x - 126, center_y - 54], 
                 fill=(240, 240, 240, 255))
    
    # Fosas nasales
    draw.ellipse([center_x - 160, center_y - 76,
                  center_x - 156, center_y - 72], 
                 fill=(60, 47, 207, 255))
    draw.ellipse([center_x - 160, center_y - 64,
                  center_x - 156, center_y - 60], 
                 fill=(60, 47, 207, 255))
    
    # Ranura para monedas
    draw.rectangle([center_x - 80, center_y - 40,
                    center_x + 40, center_y - 28], 
                   fill=(60, 47, 207, 255))
    
    # Patas
    for i, x_offset in enumerate([-160, -60, 60, 160]):
        draw.ellipse([center_x + x_offset - 15, center_y + 120,
                      center_x + x_offset + 15, center_y + 160], 
                     fill=(255, 255, 255, 255))
    
    # Moneda dorada
    coin_x, coin_y = center_x + 124, center_y - 116
    draw.ellipse([coin_x - 30, coin_y - 30,
                  coin_x + 30, coin_y + 30], 
                 fill=(255, 215, 0, 255))
    
    # Símbolo de dólar en la moneda
    try:
        # Intentar usar una fuente del sistema
        font = ImageFont.truetype("arial.ttf", 36)
    except:
        font = ImageFont.load_default()
    
    draw.text((coin_x, coin_y), "$", fill=(184, 134, 11, 255), 
              font=font, anchor="mm")
    
    return img

# Crear el icono
icon = create_app_icon()

# Guardar en diferentes tamaños
sizes = [512, 256, 128, 96, 72, 48, 36]
base_path = "assets/icons/"

# Crear directorio si no existe
os.makedirs(base_path, exist_ok=True)

for size in sizes:
    resized = icon.resize((size, size), Image.Resampling.LANCZOS)
    resized.save(f"{base_path}app_icon_{size}.png", "PNG")

# Guardar el icono principal
icon.save(f"{base_path}app_icon.png", "PNG")

print("Iconos creados exitosamente!")
