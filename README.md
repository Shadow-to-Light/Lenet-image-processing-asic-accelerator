# Lenet-image-processing-asic-accelerator
A high-performance CNN-based image processing accelerator, implemented using a full ASIC flow. Developed in December 2024.

This project presents a custom-designed AI accelerator chip based on the LeNet architecture, targeting image processing tasks. The design was implemented using a full **ASIC flow**, from RTL modeling and logic synthesis to place & route (P&R), and final GDSII generation.

- Supports serial processing of 100 grayscale images (11×11 pixels, 8-bit width)
- Introduced **line buffer** and **sliding convolution window**, reducing register count from **169 to 44** (a 75% reduction), significantly optimizing area and P&R complexity
- Computation core adopts a **three-stage pipeline** (Multiply → Add → Quantize) to boost operating frequency
- Leveraged **cycle-level reuse** of convolution kernels and MAC units for extreme area efficiency
- Achieved performance about **6× faster** than comparable designs (294 MHz vs. 50 MHz), with a compact core area of only **0.2 mm²**
- Fabricated using **SMIC 0.18 µm CMOS technology**
- Final project score: **99/100 (Highest in school history)**

> Developed in December 2024.

---

## 🧰 Tools Used

This project was developed using a full ASIC design toolchain, including:

- **Vim** – RTL development and editing  
- **Synopsys VCS** – Functional simulation  
- **Synopsys DVE** – Waveform viewing and debugging  
- **Design Compiler (DC)** – Logic synthesis  
- **Formality** – RTL and netlist equivalence checking  
- **IC Compiler (ICC)** – Place and route  
- **Cadence tools** – Supporting backend design and analysis (as needed)

---

## 📜 License

This project is released under the [MIT License](LICENSE).  
You are free to use, modify, and distribute the code with proper attribution.

---

## 🙏 Acknowledgements

We sincerely thank all project team members for their dedication and contributions:

- **Z. Li**, **Z. Xu**, **J. Deng**, **M. Kuang**

We also gratefully acknowledge the guidance and support from:

- **Y. W.**, **S. Li**, **Junkai Wang**, **Xuesong Qi**, **Haoyu Zheng**
