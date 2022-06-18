class clk_uvc_cfg extends uvm_object;
    `uvm_object_utils(clk_uvc_cfg)

    // General Configs
    string       freq_unit;
    int unsigned freq; // target frequency

    // Passive Configs
    int unsigned freq_margin;

    // Active Configs
    int unsigned duty_min;
    int unsigned duty_max;
    int          pjit_min; // period jitter min
    int          pjit_max; // period jitter max
    int unsigned phase_min;
    int unsigned phase_max;

    uvm_active_passive_enum is_active = UVM_ACTIVE;

    `uvm_object_new

    function void set_freq(int unsigned freq, string freq_unit = "GHz");
        this.freq = freq;

        if(!(freq_unit inside {"MHz", "GHz"})) begin
            `uvm_fatal(`gfn, $sformatf("Frequency unit %0s set is not supported", freq_unit))
        end else begin
            this.freq_unit = freq_unit;
        end
    endfunction : set_freq

    function void set_phase_range(int unsigned phase_min, int unsigned phase_max);
        if(phase_min > phase_max) begin
            this.set_phase_range(phase_max, phase_min);
        end else begin
            this.phase_min = phase_min;
            this.phase_max = phase_max;
        end
    endfunction : set_phase_range

    function void set_pjit_range(int pjit_min. int pjit_max);
        if(pjit_min > pjit_max) begin
            this.set_pjit_range(pjit_max, pjit_min);
        end else begin
            this.pjit_min = pjit_min;
            this.pjit_max = pjit_max;
        end
    endfunction : set_pjit_range

    function void set_duty_range(int unsigned duty_min. int unsigned duty_max);
        if(duty_min > duty_max) begin
            this.set_duty_range(duty_max, duty_min);
        end else begin
            if(duty_max >= 100) begin
                `uvm_fatal(`gfn, $sformatf("duty_min/max (%0d, %0d) should be within (0,100)", duty_min, duty_max))
            end else begin
                this.duty_min = duty_min;
                this.duty_max = duty_max;
            end
        end
    endfunction : set_duty_range

    function void set_active(uvm_active_passive_enum is_active);
        this.is_active = is_active;
    endfunction : set_active

endclass : clk_uvc_cfg
