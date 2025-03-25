#include <ThingerESP32.h>
#include <Adafruit_GFX.h>
#include <Adafruit_ST7735.h>
#include <SPI.h>

// Pines del TFT
#define TFT_CS    5
#define TFT_RST   4  
#define TFT_DC    2

Adafruit_ST7735 tft = Adafruit_ST7735(TFT_CS, TFT_DC, TFT_RST);

// Credenciales de Thinger.io
#define USERNAME "uzhcapablo"
#define DEVICE_ID "ESP"
#define DEVICE_CREDENTIAL "pablo03"

// Credenciales WiFi
#define SSID "R7"
#define PASSWORD "123456789"

ThingerESP32 thing(USERNAME, DEVICE_ID, DEVICE_CREDENTIAL);

bool mostrarMensaje = false;

void setup() {
  Serial.begin(115200);

  // Inicialización de la pantalla TFT
  tft.initR(INITR_BLACKTAB);
  tft.setRotation(1);  // Orientación horizontal
  tft.fillScreen(ST77XX_BLACK);

  // Conexión WiFi
  thing.add_wifi(SSID, PASSWORD);

  // Recurso para Thinger.io
  thing["MostrarMensaje"] << [](pson &in){
    if(in.is_empty()){     
      in = mostrarMensaje;  // Retorna el estado actual a Thinger.io
    }
    else{                  
      mostrarMensaje = in;  // Actualiza el estado cuando se recibe un comando
    }
  };
}

void loop() {
  thing.handle();

  if (mostrarMensaje) {
    mostrarTextoDesplazable("Bienvenidos a mi defensa de mi proyecto");
  } else {
    tft.fillScreen(ST77XX_BLACK); // Limpia la pantalla si no se muestra el mensaje
  }
}

void mostrarTextoDesplazable(String texto) {
  int16_t x = tft.width();
  int16_t y = tft.height() / 2 - 4;

  tft.setTextColor(ST77XX_WHITE);
  tft.setTextSize(1);

  while (x > -texto.length() * 6 && mostrarMensaje) {
    tft.fillScreen(ST77XX_BLACK);
    tft.setCursor(x, y);
    tft.print(texto);
    x -= 1;  // Velocidad del desplazamiento
    delay(50);  // Control de la velocidad de desplazamiento
  }
}
