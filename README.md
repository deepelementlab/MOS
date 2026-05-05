<p align="center">
 <!-- <img width="256" height="256" alt="MOS" src="https://github.com/user-attachments/assets/2e99ce0c-85c7-480e-acb2-f61ceb3a5808" /> -->
<img width="256" height="256" alt="MOS-A" src="https://github.com/user-attachments/assets/c33708fa-7037-4a4a-b27b-f6d3349192a9" />
<!-- <img width="256" height="256" alt="MOS-B" src="https://github.com/user-attachments/assets/35ee83c9-2705-49c6-b6d4-ab46dc92dbf7" /> -->



</p>

<!-- <h1 align="center">MOS</h1> -->

<p align="center">
  <strong>New technology, new possibilities.</strong>
</p>

## Overview
This is a research-oriented project, not intended to reinvent the wheel. It aims to validate the effectiveness of the new open-factory development paradigm for underlying system development, while exploring potentially superior technical pathways for AI-native operating systems. Guided by the IDD philosophy, with the DPAI design language as its core and OSSpec as its foundation, this project undertakes a ground-up (from 0 to 1) attempt at an operating system.


## Vision
A modern operating system designed for the AI era, combining the best features of Linux, Solaris, Windows, iOS, and Android while addressing historical shortcomings and limitations.

## Core Design Principles

### 1. **Best of All Worlds**
- **Linux**: Open-source transparency, powerful toolchain, server-grade stability
- **Solaris**: Enterprise level file system features (snapshot, compression, deduplication), and powerful dynamic tracking tool.
- **Windows**: Broad hardware compatibility, enterprise ecosystem, productivity tools
- **iOS**: Fluid user experience, security sandboxing, unified visual design  
- **Android**: Open app ecosystem, flexible customization, multi-device adaptation

### 2. **Avoid Historical Pitfalls**
- **No fragmentation**: Unified core design to prevent version splits
- **No legacy burden**: Modern architecture without backward compatibility constraints
- **Security-first**: Built-in security model from the ground up
- **Resource efficiency**: Optimized scheduling for embedded to server-scale

### 3. **AI-Native Architecture**
- Built-in AI inference engine and acceleration framework
- Intelligent resource scheduling with predictive optimization
- Natural language interaction interfaces
- Adaptive UI and personalized experiences

## System Architecture

### Microkernel Design

```
┌─────────────────────────────────────────────────────────────────────┐
│                            Applications                             │
├─────────────────────────────────────────────────────────────────────┤
│                     Application Framework Layer                     │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌────────────┐    │
│  │ Web/TS App │  │  Rust App  │  │ Python App │  │  Wasm App  │    │
│  │ Framework  │  │ Framework  │  │ Framework  │  │  Runtime   │    │
│  └────────────┘  └────────────┘  └────────────┘  └────────────┘    │
├─────────────────────────────────────────────────────────────────────┤
│                     System Services Layer                           │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                     POSIX Compatibility                      │  │
│  │              (Optional, for Legacy Support)                  │  │
│  └──────────────────────────────────────────────────────────────┘  │
│  ┌───────┐  ┌───────┐  ┌───────┐  ┌───────┐  ┌───────┐  ┌───────┐ │
│  │ File  │  │ Net   │  │  AI   │  │  GUI  │  │ Audio │  │  I/O  │ │
│  │ Server│  │Server │  │Server │  │Server │  │Server │  │Server │ │
│  └───────┘  └───────┘  └───────┘  └───────┘  └───────┘  └───────┘ │
├─────────────────────────────────────────────────────────────────────┤
│                     Microkernel (MOS Kernel)                        │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────┬─────────┐    │
│  │ Process │ Memory  │   IPC   │ Thread  │  Timer  │ Drivers │    │
│  │ Manager │ Manager │  System │ Scheduler│ Manager │ Manager │    │
│  └─────────┴─────────┴─────────┴─────────┴─────────┴─────────┘    │
└─────────────────────────────────────────────────────────────────────┘
```


### Key Components

#### **MOS Kernel (Microkernel)**
- Minimal trusted computing base
- Capability-based security model
- Real-time scheduling support
- Cross-architecture abstraction layer

#### **AI Subsystem**
- **MOS AI Runtime**: Unified AI/ML inference engine
- **Neural Processing Unit (NPU) abstraction**
- **Model Zoo & Repository**: Pre-trained models and optimization
- **Federated Learning Framework**: Privacy-preserving AI training

#### **Security Architecture**
- **Zero Trust Default**: No component inherently trusted
- **Capability-Based Access Control**
- **Hardware-backed Attestation**
- **Containerized Application Sandboxing**

#### **Resource Management**
- **Predictive Scheduling**: AI-driven workload prediction
- **Energy-Aware Power Management**
- **Quality of Service (QoS) guarantees**
- **Hot-swappable component architecture**

## Technology Stack

### Programming Languages
- **System Layer**: Rust (memory safety, performance)
- **Middleware**: Zig (systems programming, C interop)
- **Application Framework**: TypeScript/React Native (cross-platform)
- **AI/ML**: Python with Rust bindings

### Key Technologies
- **Virtualization**: KVM-based lightweight containers
- **File System**: COW (Copy-on-Write) with versioning
- **Networking**: eBPF-based network stack
- **Graphics**: Vulkan-native rendering pipeline

## Development Roadmap

### Phase 1: Foundation (0-6 months)
- [ ] Microkernel prototype
- [ ] Basic driver framework
- [ ] Cross-compilation toolchain
- [ ] Build system and CI/CD pipeline

### Phase 2: Core Services (6-12 months)
- [ ] File system and storage stack
- [ ] Network subsystem
- [ ] Security framework
- [ ] Basic graphical shell

### Phase 3: AI Integration (12-18 months)
- [ ] AI runtime and framework
- [ ] Model management system
- [ ] Natural language interface
- [ ] Adaptive UI components

### Phase 4: Ecosystem (18-24 months)
- [ ] App SDK and development tools
- [ ] Package management system
- [ ] Developer documentation
- [ ] Community infrastructure

## UI/UX Design Guidelines (Together.ai Style)

### Design Principles
- **Minimalist**: Clean interfaces with focused functionality
- **Dark-Native**: Dark theme optimized for extended use
- **Vibrant Accents**: Strategic use of color for important elements
- **Technical Precision**: Data-driven interfaces with clear metrics
- **Approachable Complexity**: Make advanced features accessible

### Visual Language
- **Typography**: Inter font family with clear hierarchy
- **Colors**: Dark backgrounds (#0a0a0f) with vibrant accents (#00d4ff)
- **Spacing**: 8px grid system for consistent layout
- **Components**: Card-based design with soft rounded corners
- **Animations**: Subtle, functional transitions (max 300ms)

### Target Platforms
- **Desktop**: Productivity-focused workflow optimization
- **Mobile**: Seamless cross-device synchronization
- **Server**: Headless operation with API-first design
- **Embedded**: Resource-constrained but full-featured

## Getting Started

### Prerequisites
- Rust toolchain (latest stable)
- LLVM/Clang compiler
- QEMU for emulation testing
- Git for version control

### Build Instructions
```bash
# Clone repository
git clone https://github.com/mos-os/mos
cd mos

# Build the kernel
cargo build --release --target x86_64-unknown-mos

# Run in emulator
make run-qemu
```

## Contributing
MOS is an open-source project under the Apache 2.0 license. We welcome contributions from developers interested in building the future of operating systems.

## License
Apache 2.0
