library verilog;
use verilog.vl_types.all;
entity ff_DE is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        pcplus4_D       : in     vl_logic_vector(31 downto 0);
        srca_D          : in     vl_logic_vector(31 downto 0);
        writedata_D     : in     vl_logic_vector(31 downto 0);
        shiftedimm_D    : in     vl_logic_vector(31 downto 0);
        instr_D25       : in     vl_logic_vector(4 downto 0);
        instr_D20       : in     vl_logic_vector(4 downto 0);
        instr_D15       : in     vl_logic_vector(4 downto 0);
        ex_D            : in     vl_logic_vector(4 downto 0);
        mem_D           : in     vl_logic_vector(3 downto 0);
        wb_D            : in     vl_logic_vector(2 downto 0);
        pcplus4_E       : out    vl_logic_vector(31 downto 0);
        srca            : out    vl_logic_vector(31 downto 0);
        writedata_E     : out    vl_logic_vector(31 downto 0);
        shiftedimm      : out    vl_logic_vector(31 downto 0);
        instr_25        : out    vl_logic_vector(4 downto 0);
        instr_20        : out    vl_logic_vector(4 downto 0);
        instr_15        : out    vl_logic_vector(4 downto 0);
        alusrc          : out    vl_logic;
        regdst          : out    vl_logic_vector(1 downto 0);
        aluop           : out    vl_logic_vector(1 downto 0);
        mem_E           : out    vl_logic_vector(3 downto 0);
        wb_E            : out    vl_logic_vector(2 downto 0)
    );
end ff_DE;
