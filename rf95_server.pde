//rf95_server.pde
//moi thiet bi se duoc danh 1 ID bang tay. thiet bi nay co ID la 005;
//kn0 yeu cau ket noi voi node cha
//kt1 la cho ket noi voi cac node co tin hieu muc cao
//kt2 la cho ket noi voi cac node co tin hieu muc thap
//kg0 yeu cau cac node con gui du lieu len node cha
//kg1 tin hieu nhan duoc tu node con
//tc0  chap nhan ket noi
//tc1 du lieu truyen ID cua node con
#include <SPI.h>
#include <RH_RF95.h>
RH_RF95 rf95;
int led = 8;
uint8_t id[] = "101";
uint8_t idnodecon[100][4];
unsigned long time = 0;
unsigned long time1 = 0;
unsigned long time2 = 0;
int state = 0;  //state = 0; la trang thai ban dau can thic hien ket noi
int dem = 0;
int idgateway = 1;
int bac = 1;
int idnode = 1;
int sonodecon = 1;
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
			if (a[0] == 'k'&& a[1] == 'n'&& a[2] == '0'&& rssi > -30)  // kiem tra tin hieu xem co node nao yeu cau ket noi hay khong
			{
				Serial.println("thuc hien ket noi muc 1");
				Serial.println("node con co the ket noi voi tin hieu muc cao");
				uint8_t data[30] = "kt1"; //kt1 la cho ket noi voi cac node co tin hieu muc cao
				kn0(data, a);
			}
			else if (a[0] == 't'&& a[1] == 'c'&& a[2] == '0'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2]) //them id cua node con vao danh sach
			{
				tc0(a);
			}
			else if (a[0] == 't'&& a[1] == 'c'&& a[2] == '1'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2])
			{
				tc1(a);
			}
			digitalWrite(led, LOW);
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
			Serial.print("RSSI: ");
			int rssi = rf95.lastRssi();
			Serial.println(rssi);
			if (a[0] == 'k'&& a[1] == 'n'&& a[2] == '0'&& rssi < -30)
			{
				Serial.println("thuc hien ket noi muc 2");
				uint8_t data[30] = "kt2"; //kt1 la cho ket noi voi cac node co tin hieu muc cao
				kn0(data, a);
			}
			else if (a[0] == 't'&& a[1] == 'c'&& a[2] == '0'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2])
			{
				tc0(a);
			}
			else if (a[0] == 't'&& a[1] == 'c'&& a[2] == '1'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2])
			{
				tc1(a);
			}
			digitalWrite(led, LOW);
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
			Serial.print("RSSI: ");
			int rssi = rf95.lastRssi();
			Serial.println(rssi);
			uint8_t *a = (uint8_t*)buf;
			if (a[0] == 'k'&& a[1] == 'g'&& a[2] == '1'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2])
			{
				Serial.print("du lieu nhan duoc tu node con: ");
				for (int i = 0; i < 15; i++)
				{
					Serial.print(a[i]);

					Serial.print(" ");
				}
				Serial.println(" ");
				for (int i = 0; i <= 99; i++)
				{
					if (idnodecon[i][0] == '1')
					{
						if (a[6] == (idnodecon[i][1]) && a[7] == (idnodecon[i][2]) && a[8] == (idnodecon[i][3]))
						{
							uint8_t data[30] = "dn1"; //dn1 gui hieu phan roi da nhan cho node con
							data[3] = id[0];
							data[4] = id[1];
							data[5] = id[2];
							data[6] = a[6];
							data[7] = a[7];
							data[8] = a[8];
							rf95.send(data, sizeof(data));
							rf95.waitPacketSent();
							i = 101;
						}
					}
				}
			}
			else if (a[0] == 'k'&& a[1] == 'n'&& a[2] == '0')
			{
				Serial.println("thuc hien ket noi ");
				uint8_t data[30] = "kt3"; //kt3 cho ket noi voi cac node 
				kn0(data, a);
				digitalWrite(led, LOW);
			}
			else if (a[0] == 't'&& a[1] == 'c'&& a[2] == '0'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2])
			{
				tc0(a);
			}
			else if (a[0] == 't'&& a[1] == 'c'&& a[2] == '1'&&a[3] == id[0] && a[4] == id[1] && a[5] == id[2])
			{
				tc1(a);
			}
			digitalWrite(led, LOW);
		}
		else
		{
			Serial.println("recv failed");

		}
	}
}

void kn0(uint8_t data[],uint8_t a[])
{
	uint8_t data1[30];
	data1[0] = data[0];
	data1[1] = data[1];
	data1[2] = data[2];
	data1[3] = id[0];
	data1[4] = id[1];
	data1[5] = id[2];
	data1[6] = a[3];
	data1[7] = a[4];
	data1[8] = a[5];
	data1[9] = (uint8_t)idgateway;
	data1[10] = (uint8_t)bac;
	data1[11] = (uint8_t)idnode;
	data1[12] = (uint8_t)sonodecon;
	rf95.send(data1, sizeof(data1));
	rf95.waitPacketSent();
	Serial.println("Sent a reply");
}

void tc0(uint8_t a[])
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
			sonodecon = sonodecon + 1;
			i = 101;
		}
	}
}

void tc1(uint8_t a[])
{
	Serial.print("dia chi ID node: ");
	for (int i = 0; i < 15; i++)
	{
		Serial.print(a[i]);

		Serial.print(" ");
	}
	Serial.println(" ");
}