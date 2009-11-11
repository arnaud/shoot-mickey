--***********************************************************
-- Contrôleur souris
-- Gère et retourne des coordonnées actualisées XP et YP
-- maintenues à l'intérieur d'un espace VGA 640 x 480
-- Fait appel au component IPS
--***********************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
---------------------------------------------------
entity souris is
	port (clock, raz : in std_logic;
		  MOUSE_DATA : inout std_logic;
	     MOUSE_CLK : in std_logic;
		  XP : out integer range 0 to 799;
	     YP : out integer range 0 to 524;
		  BG : out std_logic;
		  BD : out std_logic
		 );
end SOURIS;
---------------------------------------------------
architecture comp_souris of souris is 

signal DELTA_X, DELTA_Y : STD_LOGIC_VECTOR (7 downto 0);
signal X : integer range 0 to 799;
signal Y : integer range 0 to 524;
signal SIGN_X, SIGN_Y : std_logic;
--signal OVX,OVY :std_logic;
signal DATAAV : std_logic;

component IPS is
    port (
        data_io: inout STD_LOGIC;	-- Linea de datos del raton
        rclk: in STD_LOGIC;	-- Reloj puesto por el raton
        dataval: out STD_LOGIC;	-- Linea que habilita la captura de los datos leidos 
        			-- en el bloque Gestor. No se activara si hay paridad erronea
        despx: out STD_LOGIC_VECTOR (7 downto 0);	-- Desplazamiento relativo horiz
        despy: out STD_LOGIC_VECTOR (7 downto 0);	-- Desplazamiento relativo vert
        left: out STD_LOGIC;
        right: out STD_LOGIC;
        signox: out STD_LOGIC;	-- Signo horiz: '1' a la izquierda
        signoy: out STD_LOGIC;	-- Signo vert: '1' arriba
        --desbordx: out STD_LOGIC; -- Desbordamiento en direccin horizontal.
        --desbordy: out STD_LOGIC; -- Desbordamiento en direccin vertical.
        
        reset: in STD_LOGIC;
        clk: in STD_LOGIC
    );
end component;
---------------------------------------------------

begin
XP <= X;
YP <= Y;

---------------------------------------------------

-- Instanciation de la souris
INSTANCE_SOURIS : IPS     port map(
        data_io => MOUSE_DATA,		-- Linea de datos del raton
        rclk => MOUSE_CLK,			-- Reloj puesto por el raton
        dataval => DATAAV, 			-- Linea que habilita la captura de los datos leidos 
        							-- en el bloque Gestor. No se activara si hay paridad erronea
        despx => DELTA_X,			-- Desplazamiento relativo horiz
        despy => DELTA_Y,			-- Desplazamiento relativo vert
        left => BG,
        right => BD,
        signox => SIGN_X,	-- Signo horiz: '1' a la izquierda
        signoy => SIGN_Y,	-- Signo vert: '1' arriba
        --desbordx => OVX, 	-- Desbordamiento en direccin horizontal. NU
        --desbordy => OVY, 	-- Desbordamiento en direccin vertical. NU
        
        reset => RAZ,
        clk => CLOCK
    );

---------------------------------------------------
P_X : process (CLOCK,RAZ,SIGN_X,DELTA_X)
variable DX : integer  range  0 to 255;
begin 

if SIGN_X = '0' then DX:= CONV_INTEGER(DELTA_X) ;
else DX := 256 - CONV_INTEGER(DELTA_X) ;
end if;

if RAZ = '1' then X <= 0;
elsif CLOCK'event and CLOCK = '1' then
	if DATAAV = '1' then -- ce signal ne dure que une periode de clock
		if SIGN_X = '0' and X <639 then -- souris vers la droite
				X <= x + DX;
		elsif SIGN_X ='1' and X>=DX then -- souris vers la gauche, négatif
			 	X <= x - DX;
		end if;

	end if;
end if;
end process P_X;
---------------------------------------------------
P_Y : process (CLOCK,RAZ,SIGN_Y,DELTA_Y)
variable DY : integer range  0 to 255;
begin 

if SIGN_Y = '0' then DY:= CONV_INTEGER(DELTA_Y) ;
else DY := 256 - CONV_INTEGER(DELTA_Y) ;
end if;

if RAZ = '1' then Y <= 0;
elsif CLOCK'event and CLOCK = '1' then
	if DATAAV = '1' then -- ce signal ne dure que une periode de clock
		if SIGN_Y = '1' and Y <479 then -- souris vers le bas
			Y <= Y + DY;
		elsif SIGN_Y ='0' and  Y>DY then -- souris vers le haut
			Y <= Y-DY;
		end if;
	end if;
end if;
end process P_Y;
---------------------------------------------------
end comp_souris;
---------------------------------------------------

