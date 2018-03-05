library verilog;
use verilog.vl_types.all;
entity datapath is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        signext         : in     vl_logic;
        shiftl16        : in     vl_logic;
        memtoreg_D      : in     vl_logic_vector(1 downto 0);
        alusrc_D        : in     vl_logic;
        regdst_D        : in     vl_logic_vector(1 downto 0);
        regwrite_D      : in     vl_logic;
        jump            : in     vl_logic_vector(1 downto 0);
        aluop_D         : in     vl_logic_vector(1 downto 0);
        branch_D        : in     vl_logic_vector(1 downto 0);
        memwrite_IN     : in     vl_logic;
        memread_IN      : in     vl_logic;
        readdata_M      : in     vl_logic_vector(31 downto 0);
        memwrite        : out    vl_logic;
        memread         : out    vl_logic;
        pc              : out    vl_logic_vector(31 downto 0);
        instr_F         : in     vl_logic_vector(31 downto 0);
        aluout          : out    vl_logic_vector(31 downto 0);
        writedata       : out    vl_logic_vector(31 downto 0)
    );
end datapath;
