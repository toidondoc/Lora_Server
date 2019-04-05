// rf95_server.pde
// moi thiet bi se duoc danh 1 ID bang tay. thiet bi nay co ID la 003;
//kn yeu cau ket noi voi node cha
//kt1 la cho ket noi voi cac node co tin hieu muc cao
//kt2 la cho ket noi voi cac node co tin hieu muc thap
// tc0  chap nhan ket noi
#include <SPI.h>
#include <RH_RF95.h>
// Singleton instance of the radio driver
RH_RF95 rf95;
int led = 8;
uint8_t id[] = "003";
uint8_t idnodecon[100][4];
unsigned long time = 0;
unsigned long time1 = 0;
unsigned long time2 = 0;
int dem = 0;
int state = 0;  //state = 0; la trang thai ban dau can thic hien ket noi
void setup()
{
	pinMode(led, OUTPUT);
	Serial.begin(9600);
	if (!rf95.init())
		Serial.println("init failed");
	// khoi tao ban dau id
	for (int i = 0; i <= 99; i++)
	{
		for (int j = 0; j <= 3; j++)
		{
			idnodecon[i][j] = '0';
		}
	}
}

void loop()
{
	if (state == 0)
	{
		time = millis();
		state = 1;
	}
	if (state == 1)
	{

		if (millis() - time < 10000)
		{
			ketnoimuc1();
		}
		else if (millis() - time < 20000)
		{
			ketnoimuc2();
		}
		else
		{
			state = 2;
		}
	}
	if (state == 2)
	{
		nhandulieu();
	}
}

void ketnoimuc1()
{
	if (rf95.available())
	{
		uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];
		uint8_t len = sizeof(buf);
		if (rf95.recv(buf, &len))
		{
			digitalWrite(led, HIGH);
			Serial.print("tin hieu gui den: ");
			Serial.println((char*)buf);
			uint8_t *a = (uint8_t*)buf;
			Serial.print("RSSI: ");
			int rssi = rf95.lastRssi();
			Serial.println(rssi);
			if (a[0] == 'k'&& a[1] == 'n'&& a[2] == '0'&& rssi > -25)  // kiem tra tin hieu xem co node nao yeu cau ket noi hay khong
			{
				Serial.println("thuc hien ket noi muc 1");
				Serial.println("node con co the ket noi voi tin hieu muc cao");
				uint8_t data[30] = "kt1"; //kt1 la cho ket noi voi cac node co tin hieu muc cao
				data[3] = id[0];
				data[4] = id[1];
				data[5] = id[2];
				data[6] = a[3];
				data[7] = a[4];
				data[8] = a[5];
				rf95.send(data, sizeof(data));
				rf95.waitPacketSent();
				Serial.println("Sent a reply");
				digitalWrite(led, LOW);
			}
			else if (a[0] == 't'&& a[1] == 'c'&& a[2] == '0'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2]) //them id cua node con vao danh sach
			{
				for (int i = 0; i <= 99; i++)
				{
					if (idnodecon[i][0] == '0')
					{
						idnodecon[i][0] = '1';
						idnodecon[i][1] = a[6];
						idnodecon[i][2] = a[7];
						idnodecon[i][3] = a[8];
						Serial.println("luu id node con");
						i = 101;
						
					}
				}
			}
		}
		else
		{
			Serial.println("recv failed");
		}
	}
}

void ketnoimuc2()
{
	if (millis() - time1 > 4000)
	{
		time1 = millis();
	}
	else if (millis() - time1 == 4000)
	{
		Serial.println("gui du lieu yeu cau node con ket noi muc 2");
		uint8_t data[30] = "kt2"; //kt2 la cho ket noi voi cac node co tin hieu muc thap
		data[3] = id[0];
		data[4] = id[1];
		data[5] = id[2];
		rf95.send(data, sizeof(data));
		rf95.waitPacketSent();
		time1 = millis();
	}
	if (rf95.available())
	{
		uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];
		uint8_t len = sizeof(buf);
		if (rf95.recv(buf, &len))
		{
			digitalWrite(led, HIGH);
			Serial.print("tin hieu gui den: ");
			Serial.println((char*)buf);
			uint8_t *a = (uint8_t*)buf;
			Serial.print("RSSI aa: ");
			int rssi = rf95.lastRssi();
			Serial.println(rssi);
			if (a[0] == 'k'&& a[1] == 'n'&& a[2] == '0'&& rssi > -30)
			{
				Serial.println("thuc hien ket noi");
				uint8_t data[30] = "kt2"; //kt1 la cho ket noi voi cac node co tin hieu muc cao
				data[3] = id[0];
				data[4] = id[1];
				data[5] = id[2];
				data[6] = a[3];
				data[7] = a[4];
				data[8] = a[5];
				rf95.send(data, sizeof(data));
				rf95.waitPacketSent();
				Serial.println("Sent a reply");
				digitalWrite(led, LOW);
			}
			else if (a[0] == 't'&& a[1] == 'c'&& a[2] == '0'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2])
			{
				for (int i = 0; i <= 99; i++)
				{
					if (idnodecon[i][0] == '0')
					{
						idnodecon[i][0] = '1';
						idnodecon[i][1] = a[6];
						idnodecon[i][2] = a[7];
						idnodecon[i][3] = a[8];
						i = 101;
						Serial.println("luu id node con");
					}
				}
			}
		}
		else
		{
			Serial.println("recv failed");
		}
	}
}

void nhandulieu()
{
	if (dem <= 2)
	{
		if (millis() - time2 > 4000)
		{
			time2 = millis();
		}
		else if (millis() - time2 == 4000)
		{
			Serial.println("gui du lieu yeu cau node con gui du lieu");
			// Send a message to rf95_server
			uint8_t data[30] = "kg0"; // kg0 yeu cau node con bat dau gui du lieue len node cha
			data[3] = id[0];
			data[4] = id[1];
			data[5] = id[2];
			rf95.send(data, sizeof(data));
			rf95.waitPacketSent();
			time2 = millis();
			dem = dem + 1;
		}
	}

	if (rf95.available())
	{
		uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];
		uint8_t len = sizeof(buf);
		if (rf95.recv(buf, &len))
		{
			digitalWrite(led, HIGH);
			Serial.print("tin hieu gui den: ");
			Serial.println((char*)buf);

			uint8_t *a = (uint8_t*)buf;
			if (a[0] == 'k'&& a[1] == 'g'&& a[2] == '1'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2])
				Serial.print("du lieu nhan duoc tu node con: ");
			for (int i = 0; i < 15; i++)
			{
				Serial.print(a[i]);

				Serial.print(" ");
			}
			Serial.println(" ");
			{
				for (int i = 0; i <= 99; i++)
				{
					if (idnodecon[i][0] == '1')
					{
						if (a[6] == (idnodecon[i][1]) && a[7] == (idnodecon[i][2]) && a[8] == (idnodecon[i][3]))
						{
							Serial.println((char*)buf);
							uint8_t data[30] = "dn1"; //dn1 gui hieu phan roi da nhan cho node con
							data[3] = id[0];
							data[4] = id[1];
							data[5] = id[2];
							data[6] = a[6];   /// data[6]->data[8] la giu lieu do duoc nhu nhiet do, do am..
							data[7] = a[7];
							data[8] = a[8];
							rf95.send(data, sizeof(data));
							rf95.waitPacketSent();
							i = 101;
						}
					}
				}
			}
			if (a[0] == 'k'&& a[1] == 'n'&& a[2] == '0')
			{
				Serial.println("thuc hien ket noi ");
				uint8_t data[30] = "kt3"; //kt3 cho ket noi voi cac node 
				data[3] = id[0];
				data[4] = id[1];
				data[5] = id[2];
				data[6] = a[3];
				data[7] = a[4];
				data[8] = a[5];
				rf95.send(data, sizeof(data));
				rf95.waitPacketSent();
				Serial.println("Sent a reply");
				digitalWrite(led, LOW);
			}
			else if (a[0] == 't'&& a[1] == 'c'&& a[2] == '0'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2])
			{
				for (int i = 0; i <= 99; i++)
				{
					if (idnodecon[i][0] == '0')
					{
						idnodecon[i][0] = '1';
						idnodecon[i][1] = a[6];
						idnodecon[i][2] = a[7];
						idnodecon[i][3] = a[8];
						i = 101;
						Serial.println("luu id node con");
					}
				}
			}
			digitalWrite(led, LOW);
		}
		else
		{
			Serial.println("recv failed");
		}
	}
}