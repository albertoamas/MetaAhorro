import os
from PIL import Image, ImageDraw

def create_simple_icon():
    size = 512
    img = Image.new('RGB', (size, size), (60, 47, 207))  # Color base
    draw = ImageDraw.Draw(img)
    
    # Círculo blanco de fondo
    center = size // 2
    radius = 180
    draw.ellipse([center - radius, center - radius, 
                  center + radius, center + radius], 
                 fill=(255, 255, 255))
    
    # Icono de ahorro (círculo más pequeño con símbolo)
    inner_radius = 120
    draw.ellipse([center - inner_radius, center - inner_radius,
                  center + inner_radius, center + inner_radius], 
                 fill=(60, 47, 207))
    
    # Símbolo de dólar grande
    # Líneas verticales del $
    line_width = 20
    draw.rectangle([center - line_width//2, center - 80,
                    center + line_width//2, center + 80], 
                   fill=(255, 255, 255))
    
    # S del dólar (aproximado con rectángulos)
    # Parte superior
    draw.rectangle([center - 60, center - 60,
                    center + 60, center - 20], 
                   fill=(255, 255, 255))
    # Parte media
    draw.rectangle([center - 60, center - 20,
                    center + 60, center + 20], 
                   fill=(255, 255, 255))
    # Parte inferior  
    draw.rectangle([center - 60, center + 20,
                    center + 60, center + 60], 
                   fill=(255, 255, 255))
    
    # Recortar las partes para hacer la S
    # Quitar esquina superior derecha
    draw.rectangle([center + 20, center - 60,
                    center + 60, center - 20], 
                   fill=(60, 47, 207))
    # Quitar esquina inferior izquierda
    draw.rectangle([center - 60, center + 20,
                    center - 20, center + 60], 
                   fill=(60, 47, 207))
    
    return img

# Crear el icono
try:
    icon = create_simple_icon()
    
    # Crear directorio si no existe
    os.makedirs("assets/icons", exist_ok=True)
    
    # Guardar el icono
    icon.save("assets/icons/app_icon.png", "PNG")
    print("Icono creado exitosamente")
    
except Exception as e:
    print(f"Error: {e}")
