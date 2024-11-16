/*
******************************************************************************
**  File        : LinkerScript.ld
**  Author      : STM32CubeMX (Updated)
**  Target      : STM32F411CEUx (512K Flash, 128K RAM)
**  Description : Updated linker script for STM32
******************************************************************************
*/

/* Entry Point */
ENTRY(Reset_Handler)

/* Memory Configuration */
MEMORY
{
    RAM   (xrw)  : ORIGIN = 0x20000000, LENGTH = 128K  /* Internal SRAM */
    FLASH (rx)   : ORIGIN = 0x08000000, LENGTH = 512K  /* Main Program Flash */
}

/* Stack and Heap Sizes */
_Min_Heap_Size   = 0x800;  /* 2KB Heap */
_Min_Stack_Size  = 0x1000; /* 4KB Stack */

/* Define top of stack */
_estack = ORIGIN(RAM) + LENGTH(RAM);

/* Output Sections */
SECTIONS
{
    /* Vector Table and Reset Handler */
    .isr_vector :
    {
        . = ALIGN(4);
        KEEP(*(.isr_vector)) /* Keep the vector table */
        . = ALIGN(4);
    } > FLASH

    /* Read-Only Code Section */
    .text :
    {
        . = ALIGN(4);
        *(.text)         /* Main code */
        *(.text*)        /* Additional text sections */
        *(.glue_7)
        *(.glue_7t)
        *(.eh_frame)

        KEEP(*(.init))
        KEEP(*(.fini))

        . = ALIGN(4);
        _etext = .;      /* End of .text section */
    } > FLASH

    /* Read-Only Data Section */
    .rodata :
    {
        . = ALIGN(4);
        *(.rodata)       /* Constant data */
        *(.rodata*)      /* Constant strings */
        . = ALIGN(4);
    } > FLASH

    /* Exception Handling Sections */
    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } > FLASH

    .ARM :
    {
        __exidx_start = .;
        *(.ARM.exidx*)
        __exidx_end = .;
    } > FLASH

    /* C++ Static Initialization */
    .preinit_array :
    {
        PROVIDE_HIDDEN(__preinit_array_start = .);
        KEEP(*(.preinit_array*))
        PROVIDE_HIDDEN(__preinit_array_end = .);
    } > FLASH

    .init_array :
    {
        PROVIDE_HIDDEN(__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array*))
        PROVIDE_HIDDEN(__init_array_end = .);
    } > FLASH

    .fini_array :
    {
        PROVIDE_HIDDEN(__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array*))
        PROVIDE_HIDDEN(__fini_array_end = .);
    } > FLASH

    /* Initialized Data Section (Load in FLASH, Run in RAM) */
    _sidata = LOADADDR(.data);
    .data :
    {
        . = ALIGN(4);
        _sdata = .;
        *(.data)
        *(.data*)
        . = ALIGN(4);
        _edata = .;
    } > RAM AT> FLASH

    /* Uninitialized Data Section (Zero Initialized) */
    .bss :
    {
        . = ALIGN(4);
        _sbss = .;
        __bss_start__ = _sbss;
        *(.bss)
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
        __bss_end__ = _ebss;
    } > RAM

    /* User Heap and Stack Area */
    ._user_heap_stack :
    {
        . = ALIGN(8);
        PROVIDE(end = .);
        PROVIDE(_end = .);
        . = . + _Min_Heap_Size;   /* Allocate heap size */
        . = . + _Min_Stack_Size;  /* Allocate stack size */
        . = ALIGN(8);
        __heap_end__ = .;         /* End of heap and stack */
    } > RAM

    /* Debug Info Sections */
    .debug_info 0 : { *(.debug_info) }
    .debug_abbrev 0 : { *(.debug_abbrev) }
    .debug_loc 0 : { *(.debug_loc) }
    .debug_aranges 0 : { *(.debug_aranges) }
    .debug_line 0 : { *(.debug_line) }
    .debug_str 0 : { *(.debug_str) }
    .debug_ranges 0 : { *(.debug_ranges) }

    /* Discard Unused Sections */
    /DISCARD/ :
    {
        *(.comment)
        *(.note*)
        libc.a ( * )
        libm.a ( * )
        libgcc.a ( * )
    }
}