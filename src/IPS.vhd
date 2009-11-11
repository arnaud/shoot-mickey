library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ips is
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
        desbordx: out STD_LOGIC; -- Desbordamiento en direccin horizontal.
        desbordy: out STD_LOGIC; -- Desbordamiento en direccin vertical.
        
        reset: in STD_LOGIC;
        clk: in STD_LOGIC
    );
end ips;

architecture ips_arch of ips is

type estado is (reposo, tbit0, tbit1, tbit2, tbit3, tbit4, 
   tbit5, tbit6, tbit7, tpari, bit_stop, espera_start, bit0, bit1, 
   bit2, bit3, bit4, bit5, bit6, bit7, bit_paridad,comp_pari, gestor_lee,espbitstop);
signal  estact, estfut: estado;
signal	p_ntrama, ntrama: integer range 0 to 2; -- Para saber en cada estado en que trama se esta.
signal	error: std_logic; -- Indica error de Tx, tanto por paridad como por  
			  -- error en la numeracion de tramas.
signal	rclk_ant: std_logic;
signal	paraux:   std_logic;
 
signal  ack, p_ack: std_logic;  -- indica lectura de ID del raton
signal	p_data, paridad, rflanco:  std_logic;				  
signal	p_left, lefti, p_right, righti, p_signox, signoxi, p_signoy, signoyi: std_logic;
signal  p_desbordx, desbordxi, p_desbordy, desbordyi, p_dataval, datavali: std_logic;
signal  error_interno, data, dir_out, datar, p_datar: std_logic;
signal  p_despx, despxi, p_despy, despyi: std_logic_vector (7 downto 0);
signal  rclk_deglitch, p_rclk_deglitch: std_logic;
begin



data_io <= data when dir_out = '1' else 'Z';
datar<=data_io;

limpia: process(rclk, rclk_ant, rclk_deglitch)
begin
   rflanco <= '0';
   if (rclk = '1' and rclk_ant = '1' and rclk_deglitch = '0') then
     p_rclk_deglitch <= '1';
   elsif (rclk = '0' and rclk_ant = '0' and rclk_deglitch = '1') then
     p_rclk_deglitch <= '0';
     rflanco <= '1';
   else
     p_rclk_deglitch <= rclk_deglitch;
   end if;
end process;

maq_estados: process(lefti, righti, signoxi, signoyi, desbordxi, desbordyi, datavali, 
         despxi, despyi, data, datar, rclk, estact, ntrama, rclk_ant, paraux, error,
         rflanco, ack)
begin
        p_ntrama <= ntrama;
        paridad<=paraux;
        p_left <= lefti;
        p_right<=righti;
        p_signox<=signoxi;
        p_signoy<=signoyi;
        p_desbordx<=desbordxi;
        p_desbordy<=desbordyi;
        p_despx<=despxi;
        p_despy<=despyi;
        p_dataval<='0';
	error_interno <= error;       --En un ppio,error_interno es cero 

	
	p_ack<=ack;
	p_data <= data;	
	case estact is
		when reposo=>
			dir_out <= '1';   --data_io<=data
			p_data<='0';
			p_ack<='0';
			if (rflanco= '1') then
				estfut<=tbit0;
			else
				estfut<=reposo;
			end if;		
		when tbit0=>
			p_data<='0';
			dir_out <= '1';
			if (rflanco = '1') then
				estfut<=tbit1;  
			else
				estfut<=tbit0;
			end if;	
		when tbit1=>
			p_data<='0';
			dir_out <= '1';
			if (rflanco = '1') then
				estfut<=tbit2;  
			else
				estfut<=tbit1;
			end if;
		when tbit2=>
			p_data<='1';
			dir_out <= '1';
			if (rflanco = '1') then
				estfut<=tbit3;  
			else
				estfut<=tbit2;
			end if;
		when tbit3=>
			p_data<='0';
			dir_out <= '1';
			if (rflanco = '1') then
				estfut<=tbit4;  
			else
				estfut<=tbit3;
			end if;
		when tbit4=>
			p_data<='1';
			dir_out <= '1';
			if (rflanco = '1') then
				estfut<=tbit5;  
			else
				estfut<=tbit4;
			end if;
		when tbit5=>
			p_data<='1';
			dir_out <= '1';
			if (rflanco = '1') then
				estfut<=tbit6;  
			else
				estfut<=tbit5;
			end if;
		when tbit6=>
			p_data<='1';
			dir_out <= '1';
			if (rflanco = '1') then
				estfut<=tbit7;  
			else
				estfut<=tbit6;
			end if;
		when tbit7=>
			p_data<='1';
			dir_out <= '1';
			if (rflanco = '1') then
				estfut<=tpari;   -- paridad de transmision  
			else
				estfut<=tbit7;
			end if;		
		when tpari=>
			p_data<='0';   -- $F4 => paridad ='0'
			dir_out <= '1';
			if (rflanco = '1') then
				estfut<=bit_stop;  
			else
				estfut<=tpari;
			end if;
		when bit_stop=>
			p_data<='1';
			dir_out <= '1';
			if (rflanco = '1') then
				dir_out <= '0';		--se ha metido esto ahora
				estfut<=espera_start;  
			else
				estfut<=bit_stop;
			end if;

		when espera_start=>  -- Espera bit de start.
		      dir_out <= '0';  						
			if (rflanco='1' and (datar='0')) then				
				estfut<=bit0; 	-- Llega flanco de rclk=>se  
					      		-- actualiza estado.				
			else 
				estfut<=espera_start;	
			end if;
		
		when bit0=>				-- Se recibe el primer bit de informacin de una trama.
		        dir_out<='0';
			if (rflanco='1') then				
				estfut<=bit1; 	-- Llega flanco de rclk=>se actualiza 
							-- estado y se lee data.
				paridad<=datar;   -- Se guarda dato para comprobacion de parid
				if (ntrama=0) then				    
				   	p_left<=datar; -- Segun la trama en la que se este se
				elsif (ntrama=1) then	-- activa la linea de salida 
					p_despx(0)<=datar;	-- correpondiente.
				else
					p_despy(0)<=datar;
				end if;										
			else 
				estfut<=bit0;	
			end if;
	-- Si iran poniendo las lineas al valor correspondiente conforme se vayan recibiendo
	-- ya que el gestor no las leera hasta que no se active dataval, al final de la 
	-- tercera trama.
		when bit1=>	-- Se recibe el primer bit de informacin de una trama.
			dir_out<='0';
			if (rflanco='1') then				
				estfut<=bit2; 	-- Llega flanco de rclk=>se actualiza 
							-- estado y se lee data.
				paridad<=paraux XOR datar;  -- Se va calculando la paridad de
									-- dos en dos bits. 
				if (ntrama=0) then				    
				   	p_right<=datar;  -- Segun la trama en la que se este se
				elsif (ntrama=1) then	-- activa la linea de salida 
					p_despx(1)<=datar;	-- correpondiente.
				else
					p_despy(1)<=datar;
				end if;						
			else 
				estfut<=bit1;	
			end if;
		when bit2=>	-- Se recibe el primer bit de informacin de una trama.	
				dir_out<='0';
				if (rflanco='1') then				
				estfut<=bit3; 	-- Llega flanco de rclk=>se actualiza 
							-- estado y se lee data.
				paridad<=paraux XOR datar;		
				if (ntrama=1) then	
					p_despx(2)<=datar;	
				elsif(ntrama=2) then
					p_despy(2)<=datar;
				end if;						
			else 
				estfut<=bit2;	
			end if;
		when bit3=>	-- Se recibe el primer bit de informacin de una trama.
			dir_out<='0';
			if (rflanco='1') then				
				estfut<=bit4; 	-- Llega flanco de rclk=>se actualiza 
							-- estado y se lee data.
				paridad<=paraux XOR datar;



				if (ntrama=1) then	-- Aqui habia un elsif 
					p_despx(3)<=datar;	
				elsif (ntrama=2) then
					p_despy(3)<=datar;
				end if;						
			else 
				estfut<=bit3;	
			end if;
		when bit4=>	-- Se recibe el primer bit de informacin de una trama.
		dir_out<='0';
			if (rflanco='1') then				
				estfut<=bit5; 	-- Llega flanco de rclk=>se actualiza 
						-- estado y se lee data.
				paridad<=paraux XOR datar;
				if (ntrama=0) then
					p_signox<=datar;	-- Segun la trama en la que se este se
				elsif (ntrama=1) then	-- activa la linea de salida 
					p_despx(4)<=datar;	-- correpondiente.
				else
					p_despy(4)<=datar;
				end if;						
			else 
				estfut<=bit4;	
			end if;
		when bit5=>	-- Se recibe el primer bit de informacin de una trama.
		dir_out<='0';
			if (rflanco='1') then				
				estfut<=bit6; 	-- Llega flanco de rclk=>se actualiza 
						-- estado y se lee data.
				paridad<=paraux XOR datar;
				if (ntrama=0) then
					p_signoy<=datar;	-- Segun la trama en la que se este se
				elsif (ntrama=1) then	-- activa la linea de salida 
					p_despx(5)<=datar;	-- correpondiente.
				else
					p_despy(5)<=datar;
				end if;						
			else 
				estfut<=bit5;	
			end if;
		when bit6=>	-- Se recibe el primer bit de informacin de una trama.
		dir_out<='0';
			if (rflanco='1') then				
				estfut<=bit7; 	-- Llega flanco de rclk=>se actualiza 
						-- estado y se lee data.
				paridad<=paraux XOR datar;
				if (ntrama=0) then
					p_desbordx<=datar;	-- Segun la trama en la que se este se
				elsif (ntrama=1) then	-- activa la linea de salida 
					p_despx(6)<=datar;	-- correpondiente.
				else
					p_despy(6)<=datar;
				end if;						
			else 
				estfut<=bit6;	
			end if;
		when bit7=>	-- Se recibe el primer bit de informacin de una trama.
		dir_out<='0';
			if (rflanco='1') then				
				estfut<=bit_paridad; -- Llega flanco de rclk=>se actualiza 
						     -- estado y se lee data.
				paridad<=paraux XOR datar;
				if (ntrama=0) then
					p_desbordy<=datar;	-- Segun la trama en la que se este se
				elsif (ntrama=1) then	-- activa la linea de salida 
					p_despx(7)<=datar;	-- correpondiente.
				else
					p_despy(7)<=datar;
				end if;						
			else 
				estfut<=bit7;	
			end if;
		when bit_paridad=>	-- Comprobacion de la paridad de la trama.
		dir_out<='0';
			if (rflanco='1') then				
				estfut<=comp_pari; -- Llega flanco de rclk 						     
				paridad<=paraux XOR datar;
			else
				estfut<=bit_paridad;
			end if;

		when comp_pari=>
			dir_out<='0';		
			if (paraux='0') then
				error_interno <= '1';
			end if;
			estfut<=gestor_lee;



		when gestor_lee=>
		-- Se pone dataval a nivel alto si no ha habido ningn error en la trama.
		-- Adems estara a ese nivel un slo ciclo de reloj, ya que este estado sera
		-- inestable.
		dir_out<='0';
		if (ack = '0') then 
			p_ntrama <= 0;
			p_ack <= '1';
			error_interno<='0';
		else
			if (ntrama=2) then
				p_ntrama<=0;
				
				if (error='1') then   -- Si hay error, dataval='0'
					p_dataval<='0';
				else
					p_dataval<='1';
				end if;
				error_interno<='0';	--se ha puesto nuevo tambien
				
			elsif (ntrama=0) then
				p_ntrama<=1;
			else
				p_ntrama<=2;
			end if;		
		end if;
		estfut<=espbitstop;

		when espbitstop=>
			dir_out<='0';
			if (rflanco='1' and datar='1') then
				estfut<=espera_start;
			else
				estfut<=espbitstop;
			end if;

			 
	end case;
end process;

sincronismo: process(clk, reset)
begin
	if (reset='1') then
		estact<=reposo;
		paraux <='0';
		rclk_ant <= '0';
		ntrama <= 0;
		error <= '0';
		lefti <= '0';	
		righti <= '0';
		signoxi <= '0';
		signoyi <= '0';
		desbordxi <= '0';
		desbordyi <= '0';
		datavali <= '0';
		despxi <= (OTHERS=>'0');
		despyi <= (OTHERS=>'0');
		data<='0';
		ack<='0';
		rclk_deglitch <= '1';
	elsif ((clk'event) and (clk='1')) then
		estact<=estfut;
		paraux<=paridad;
		rclk_ant<=rclk;
		ntrama <= p_ntrama;  
		error <= error_interno;
		lefti <= p_left;
		righti <= p_right;
		signoxi <= p_signox;
		signoyi <= p_signoy;
		desbordxi <= p_desbordx;
		desbordyi <= p_desbordy;
		datavali <= p_dataval;
		despxi <= p_despx;
		despyi <= p_despy;
		data <= p_data;
		rclk_deglitch <= p_rclk_deglitch;
		ack<=p_ack;
	end if;
end process;
	
left <= lefti;
right <= righti;
signox <= signoxi;
signoy <= signoyi;
desbordx <= desbordxi;
desbordy <= desbordyi;
dataval <= datavali;
despx <= despxi; 
despy <= despyi; 
  
end ips_arch;


