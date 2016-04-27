-- Author: David Thach
-- Date: 2016.04.28

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity video_framer is
    port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           en : in  STD_LOGIC;
           res_sel : in  STD_LOGIC;
           DE : out  STD_LOGIC;
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC);
end video_framer;

architecture behavioral of video_framer is

type hregion_type is (HINIT, HSYNC, HBACK, HACTIVE, HFRONT);
type vregion_type is (VINIT, VSYNC, VBACK, VACTIVE, VFRONT);

signal c_hr, n_hr: hregion_type;
signal c_vr, n_vr: vregion_type;
signal hpos, vpos: integer := 0;

constant hsync_px : integer := 32;
constant hback_px : integer := 80;
constant hfront_px : integer := 48;

constant vsync_lines : integer := 6;
constant vback_lines : integer := 26;
constant vfront_lines : integer := 3;

-- Resolution mode definition
constant res_width_mode0 : integer := 1920;
constant res_height_mode0 : integer := 1200;

constant res_width_mode1 : integer := 1280;
constant res_height_mode1 : integer := 1024;

signal hactive_px : integer; -- Used to store width resolution
signal vactive_lines : integer; -- Used to store height resolution

signal hsync_pos, hback_pos, hactive_pos, hfront_pos, htotal : integer;
signal vsync_pos, vback_pos, vactive_pos, vfront_pos, vtotal : integer;

begin

	region_update:
	process (clk, rst, en, res_sel)
	begin
		if (rst = '1') then
			c_hr <= HINIT;
			c_vr <= VINIT;
		elsif (en = '1') then
			if (rising_edge (clk)) then
				c_hr <= n_hr;
				c_vr <= n_vr;
			end if;
		end if;
	end process region_update;
	
	pos_update: -- Update hpos and vpos
	process (clk, rst, en, res_sel)
	variable res_width, res_height : integer;
	variable c_hpos, c_vpos : integer;
	begin
		if (rst = '1') then
			hpos <= 0;
			vpos <= 1;
		elsif (en = '1') then
			if (rising_edge (clk)) then
				-- Set resolution if VINIT & HINIT
				if ((c_hr = HINIT) and (c_vr = VINIT)) then
					if (res_sel = '0') then -- 1920 x 1200
						res_width := res_width_mode0; res_height := res_height_mode0;
					else -- 1280 x 1024
						res_width := res_width_mode1; res_height := res_height_mode1;
					end if;
					hactive_px <= res_width; vactive_lines <= res_height; -- Set resolution
					
					hsync_pos <= 1;
					hback_pos <= hsync_px;
					hactive_pos <= hsync_px + hback_px;
					hfront_pos <= hsync_px + hback_px + res_width;
					htotal <= hsync_px + hback_px + res_width + hfront_px;
					
					vsync_pos <= 1;
					vback_pos <= vsync_lines;
					vactive_pos <= vsync_lines + vback_lines;
					vfront_pos <= vsync_lines + vback_lines + res_height;
					vtotal <= vsync_lines + vback_lines + res_height + vfront_lines;
				end if;
				-- Increment hpos & vpos
				c_hpos := hpos;
				c_vpos := vpos;
				if (c_hpos = htotal) then
					if (c_vpos = vtotal) then
						vpos <= 1; -- Back to first line
					else
						vpos <= vpos + 1; -- Go to next line
					end if;
					hpos <= 1; -- Back to left side
				else
					hpos <= hpos + 1; -- Go to next pixel
				end if;
			end if;
		end if;
	end process pos_update;

	hs_process:
	process (c_hr, hpos)
	begin
		case c_hr is
			when HINIT =>
				HS <= '0'; -- now
				n_hr <= HSYNC;
			when HSYNC =>
				HS <= '1';
				if (hpos = hback_pos) then n_hr <= HBACK;
				else n_hr <= HSYNC;
				end if;
			when HBACK =>
				HS <= '0';
				if (hpos = hactive_pos) then n_hr <= HACTIVE;
				else n_hr <= HBACK;
				end if;
			when HACTIVE =>
				-- HS <= '0';
				if (hpos = hfront_pos) then n_hr <= HFRONT;
				else n_hr <= HACTIVE;
				end if;
			when HFRONT =>
				-- HS <= '0';
				if (hpos = htotal) then n_hr <= HSYNC;
				else n_hr <= HFRONT;
				end if;
		end case;
	end process hs_process;
	
	vs_process:
	process (c_vr, vpos, hpos)
	begin
		case c_vr is
			when VINIT =>
				VS <= '1';
				n_vr <= VSYNC;
			when VSYNC =>
				VS <= '0'; -- Low polarity
				if ((vpos = vback_pos) and (hpos = htotal)) then  n_vr <= VBACK;
				else n_vr <= VSYNC;
				end if;
			when VBACK =>
				VS <= '1';
				if ((vpos = vactive_pos) and (hpos = htotal)) then n_vr <= VACTIVE;
				else n_vr <= VBACK;
				end if;
			when VACTIVE =>
				-- VS <= '0';
				if ((vpos = vfront_pos) and (hpos = htotal)) then n_vr <= VFRONT;
				else n_vr <= VACTIVE;
				end if;
			when VFRONT =>
				-- VS <= '0';
				if ((vpos = vtotal) and (hpos = htotal)) then n_vr <= VSYNC;
				else n_vr <= VFRONT;
				end if;
		end case;
	end process vs_process;
	
	de_process:
	process (c_hr, c_vr)
	begin
		case c_vr is
			when VACTIVE =>
				case c_hr is
					when HACTIVE =>
						DE <= '1';
					when others =>
						DE <= '0';
				end case;
			when others =>
				DE <= '0';
		end case;
	end process de_process;
end behavioral;

