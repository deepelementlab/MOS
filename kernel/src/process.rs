//! Process management abstractions.

use serde::{Deserialize, Serialize};
use uuid::Uuid;

/// Unique process identifier.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct ProcessId(Uuid);

impl ProcessId {
    pub fn new() -> Self {
        Self(Uuid::new_v4())
    }
}

/// Process priority levels.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum Priority {
    /// AI-boosted priority — AI-native scheduling
    AiBoosted,
    /// High-priority system task
    High,
    /// Normal user process
    Normal,
    /// Low-priority background task
    Low,
    /// Idle / maintenance
    Idle,
}

/// Process state machine.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum ProcessState {
    Created,
    Running,
    Ready,
    Blocked,
    Terminated,
}

/// Core process descriptor.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Process {
    pub pid: ProcessId,
    pub name: String,
    pub state: ProcessState,
    pub priority: Priority,
    pub parent_pid: Option<ProcessId>,
    pub memory_usage: usize,
    pub cpu_time_ms: u64,
}

impl Process {
    pub fn new(name: impl Into<String>) -> Self {
        Self {
            pid: ProcessId::new(),
            name: name.into(),
            state: ProcessState::Created,
            priority: Priority::Normal,
            parent_pid: None,
            memory_usage: 0,
            cpu_time_ms: 0,
        }
    }

    pub fn with_priority(mut self, priority: Priority) -> Self {
        self.priority = priority;
        self
    }

    pub fn with_parent(mut self, parent: ProcessId) -> Self {
        self.parent_pid = Some(parent);
        self
    }
}

/// Process manager trait — to be implemented by the kernel.
pub trait ProcessManager {
    fn spawn(&mut self, name: &str, priority: Priority) -> Process;
    fn kill(&mut self, pid: ProcessId) -> Result<(), String>;
    fn list(&self) -> Vec<&Process>;
    fn find(&self, pid: ProcessId) -> Option<&Process>;
    fn set_priority(&mut self, pid: ProcessId, priority: Priority) -> Result<(), String>;
}
