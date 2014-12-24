*************************************************************************
   ____  ____ 
  /   /\/   / 
 /___/  \  /   
 \   \   \/    © Copyright 2014 Xilinx, Inc. All rights reserved.
  \   \        This file contains confidential and proprietary 
  /   /        information of Xilinx, Inc. and is protected under U.S. 
 /___/   /\    and international copyright and other intellectual 
 \   \  /  \   property laws. 
  \___\/\___\ 
 
*************************************************************************

Vendor: Xilinx 
Current readme.txt Version: 1.0.0
Date Last Modified:  03NOV2014 
Date Created: 03NOV2014

Associated Filename: rdf0306-kcu105-trd02-2014-3.zip
Associated Document: UG919

Supported Device(s): Kintex UltraScale (XCKU040-2FFVA1156E)
   
*************************************************************************

Disclaimer: 

      This disclaimer is not a license and does not grant any rights to 
      the materials distributed herewith. Except as otherwise provided in 
      a valid license issued to you by Xilinx, and to the maximum extent 
      permitted by applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE 
      "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL 
      WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
      INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, 
      NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and 
      (2) Xilinx shall not be liable (whether in contract or tort, 
      including negligence, or under any other theory of liability) for 
      any loss or damage of any kind or nature related to, arising under 
      or in connection with these materials, including for any direct, or 
      any indirect, special, incidental, or consequential loss or damage 
      (including loss of data, profits, goodwill, or any type of loss or 
      damage suffered as a result of any action brought by a third party) 
      even if such damage or loss was reasonably foreseeable or Xilinx 
      had been advised of the possibility of the same.

Critical Applications:

      Xilinx products are not designed or intended to be fail-safe, or 
      for use in any application requiring fail-safe performance, such as 
      life-support or safety devices or systems, Class III medical 
      devices, nuclear facilities, applications related to the deployment 
      of airbags, or any other applications that could lead to death, 
      personal injury, or severe property or environmental damage 
      (individually and collectively, "Critical Applications"). Customer 
      assumes the sole risk and liability of any use of Xilinx products 
      in Critical Applications, subject only to applicable laws and 
      regulations governing limitations on product liability.

THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS 
FILE AT ALL TIMES.

*************************************************************************

This readme file contains these sections:

1. REVISION HISTORY
2. OVERVIEW
3. SOFTWARE TOOLS AND SYSTEM REQUIREMENTS
4. DESIGN FILE HIERARCHY
5. INSTALLATION AND OPERATING INSTRUCTIONS
6. OTHER INFORMATION (OPTIONAL)
7. SUPPORT


1. REVISION HISTORY 

            Readme  
Date        Version      Revision Description
=========================================================================
03NOV2014   1.0          Initial Xilinx release.
=========================================================================

2. OVERVIEW

This readme describes how to use the files that come with rdf0306-kcu105-trd02-2014-3.zip 

Two designs are available: Base design and an user modification design.


The Base design is a x8 GEN3 endpoint design which uses Expresso AXI-PCIe Bridge 
and DMA from Northwest Logic. This design showcases AXI Memory Mapped Dataplane operation 
where data can be moved between Host system memory and the card memory (DDR4). 
Also provided is linux 32-bit Fedora 16 device drivers with Java based Graphical
User Interface for controlling and monitoring the TRD.

User Modification design demonstrates adding a video processing block to the base design.

3. SOFTWARE TOOLS AND SYSTEM REQUIREMENTS

 a. Hardware
     i. KCU105 board with the Kintex® UltraScale XCKU040-2FFVA1156E FPGA   
    ii. USB cable, standard-A plug to micro-B plug
   iii. Power Supply: 100 VAC¿240 VAC input, 12 VDC 5.0A output
    iv. A Host computer with PCI Express slot, DVD drive, monitor, keyboard and mouse
     v. A control computer is required for running the Vivado Design Suite and configuring the
    vi. ATX Power supply
FPGA. It can be a laptop or desktop computer with Microsoft Windows 7 operating system

 b. Software
    i.  Xilinx Vivado 2014.3 or higher
    ii. QuestaSim/Modelsim 10.2a
    iii.Fedora 16 Live DVD


Note: Before running any command line scripts, refer to the 
      Xilinx Design Tools: Installation and Licensing document to learn how 
      to set the appropriate environment variables for your operating system.
      All scripts mentioned in this readme file assume the environment for
      use of Vivado tools has been set.

4. DESIGN FILE HIERARCHY

The directory structure underneath the top-level folder is described 
below:

    kcu105_aximm_dataplane : Main Reference Design folder
    |
    +-- hardware : Hardware Design specific files and scripts for simulation & implementation
    |   +-- sources
    |   |   +-- constraints : Constraint files
    |   |   +-- hdl : Custom RTL files required for the design
    |   |   +-- ip_package : Contains the locally packaged IPs required for the IPI flow
    |   |   +-- testbench : Testbench files for Out Of Box Simulation
    |   +-- vivado
    |       +-- scripts : Contains scripts for Implementation and Simulation
    +-- ready_to_test : Prebuilt bitfiles
    |   +-- ES : This bitstream is built out of Vivado 2014.1 tool.
    |   +-- Production Silicon : This bitstream is built out of 2014.3 toolchain. Please contact the Engg team to get the 
    |                            drivers (Fedora 20) for testing the design on Prod Si.
    +-- software : Source code for linux device driver, user application and Java based GUI
    |   +-- linux_driver_app
    |       +-- driver
    |       +-- gui
    +-- quickstart.sh : Script to invoke the GUI ( Do "chmod +x quickstart.sh" on the terminal, to make it an executable)   
    +--readme.txt : the file you are currently reading  


5. INSTALLATION AND OPERATING INSTRUCTIONS 

   Install the Xilinx Vivado 2014.3 or later tools on the control computer.

   IMPLEMENTATION FLOW
   -------------------
   a. Vivado IPI flow - Base Design

     1. Open a terminal window on a Linux system, or open a Vivado Tcl shell on a Windows System.
     2. Navigate to the kcu105_aximm_dataplane/hardware/vivado/scripts/base folder.
     3. To run the implementation flow in GUI mode, enter:
           $ vivado -source kcu105_aximm_dataplane_base_design.tcl
        This opens the Vivado® Integrated Design Environment (IDE), loads the block diagram,
        and adds the required top file and XDC file to the project. 
     4. In the Flow Navigator panel, click Generate Bitstream (option), which runs synthesis,
        implementation, and generates a bitfile.
        The generated bitstream will be available in kcu105_aximm_dataplane/hardware/vivado/runs_base/kcu105_aximm_dataplane.runs/impl_1
       
      Close Vivado GUI.

      To run the implementation in batch mode, run the following command:
             $ vivado -mode batch -source kcu105_aximm_dataplane_base_design_batch.tcl
      
   b. Vivado IPI flow - User Extension Design

     1. Open a terminal window on a Linux system, or open a Vivado Tcl shell on a Windows System.
     2. Navigate to the kcu105_aximm_dataplane/hardware/vivado/scripts/user_extn folder.
     3. To run the implementation flow in GUI mode, enter:
           $ vivado -source kcu105_aximm_dataplane_user_extn.tcl
        This opens the Vivado® Integrated Design Environment (IDE), loads the block diagram,
        and adds the required top file and XDC file to the project. 
     4. In the Flow Navigator panel, click Generate Bitstream (option), which runs synthesis,
        implementation, and generates a bitfile.
        The generated bitstream will be available in kcu105_aximm_dataplane/hardware/vivado/runs_user_extn/kcu105_aximm_dataplane.runs/impl_1
       
      Close Vivado GUI.

      To run the implementation in batch mode, run the following command:
             $ vivado -mode batch -source kcu105_aximm_dataplane_user_extn_batch.tcl
      
   SIMULATION FLOW
   ---------------
   The PCI Express AXI Memory Mapped Dataplane TRD can be simulated using the QuestaSim/ModelSim only. There is no support for Vivado Simulator yet.
   See Vivado Design Suite User Guide:Logic Simulation (UG900) for information on how to run simulation 
   with different simulators.

   The test bench initializes the bridge and DMA, sets up the DMA for system-to-card (S2C)
   and card-to-system (C2S) data transfer. The testbench configures the DMA to transfer one
   64 byte packet from host memory (basically an array in the testbench) to card memory
   (DDR4 model) and readback the data from the card memory. The testbench then compares
   the data read back from the DDR4 model with the transmitted packet.

   Note: Simulation setup is provided only for the base design and not for the pre-built user
   extension design.

   The simulation testbench requires a DDR4 model. The DDR4 model for QuestaSim is obtained by generating MIG IP example design. There is a place holder for the DDR4 model under kcu105_aximm_dataplane/hardware/vivado/scripts/base/ddr4_model_vsim directory. Copy the files under DDR4 model obtained from MIG IP example design to above mentioned directory before executing the simulation script.
   
   Please refer to PG150 for steps to generate the MIG IP example design.

   a. QuestaSim/ModelSim Flow  

      1. Open a terminal window on a Linux system, or open a Vivado Tcl shell on a Windows system.
      2. Navigate to the kcu105_aximm_dataplane/hardware/vivado/scripts/base folder.
      3. To run simulation, enter:
            $ vivado -source kcu105_aximm_dataplane_base_design_mti.tcl

      This step creates the project and opens the Vivado IDE with target simulator settings set
      to QuestaSim/ModelSim Simulator. 
      4. In the Flow Navigator panel, click Run Simulation and select Run Behavioral Simulation.
         Type "run -all" at a simulator prompt after design elaboration completes and simulation is loaded.
      

6. OTHER INFORMATION  

1) Warnings - NONE

2) Design Notes
   The GUI in TRD uses jfreechart as a library and no modifications have been done to the downloaded source/JAR. jfreechart is downloaded
   from http://www.jfree.org/jfreechart/download.html and is licensed under the terms of LGPL. A copy of the source along with license is
   included in this distribution.

3) Fixes - NONE

4) Known Issues - NONE

7. SUPPORT

To obtain technical support for this reference design, go to 
www.xilinx.com/support to locate answers to known issues in the Xilinx
Answers Database.  
