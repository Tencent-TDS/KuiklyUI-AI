# KuiklyUI-AI 

> **NOTE: This repository is currently in development. Skills and rules are being progressively released and refined.**

AI can be used to build AI-driven Kuikly apps and accelerate development workflows. You can use AI tools like [Cursor](https://cursor.com/home) and [CodeBuddy](https://www.codebuddy.ai/) for code generation and scaffolding.

## Available Rules

| Rule | Description |
|---|---|
| [kuiklyDSL.mdc](rules/kuiklyDSL.mdc) | Kuikly DSL cross-platform development guidelines covering architecture, coding, UI, performance, and state management best practices. |
| [kuiklyComposeDSL.mdc](rules/kuiklyComposeDSL.mdc) | Kuikly Compose DSL cross-platform development guidelines covering component usage, API differences, and best practices. |

## Available Skills

| Skill | Description |
|---|---|
| [kuikly-ui-framework](skills/kuikly-ui-framework/SKILL.md) | Assists with Kuikly UI framework development including components (View, Text, Button, List, Image, etc.), modules (Router, Network, SP, etc.), layouts, events, and routing. Use when building Kuikly pages or working with UI components. |
| [kuikly-animation](skills/kuikly-animation/SKILL.md) | Implements animated effects in Kuikly DSL using declarative (animate + reactive variables) and imperative (animateToAttr + ViewRef) approaches. Use when adding transform, opacity, backgroundColor, or frame animations. |
| [kuikly-expand-view](skills/kuikly-expand-view/SKILL.md) | Creates custom UI components that expose native Views to the Kuikly side. Use when extending Kuikly with platform-specific UI components across Android, iOS, HarmonyOS, H5, and Mini Programs. |
| [kuikly-expand-api](skills/kuikly-expand-api/SKILL.md) | Creates custom Modules to extend native APIs and enable bidirectional communication between Kuikly and native platforms. Use when accessing platform-specific functionality not available in Kuikly core. |
| [kuikly-network-and-json](skills/kuikly-network-and-json/SKILL.md) | Handles HTTP requests and JSON data processing via Kuikly NetworkModule. Use when making network requests, parsing JSON, or uploading/downloading binary data. |
| [kuikly-reactive-observer](skills/kuikly-reactive-observer/SKILL.md) | Manages reactive state updates and template directives (vfor, vif, vbind, etc.) in Kuikly DSL. Use when implementing data-driven UI updates, list rendering, or conditional rendering. |
| [kuikly-coroutines-threading](skills/kuikly-coroutines-threading/SKILL.md) | Guides asynchronous programming with Kuikly built-in coroutines, kotlinx coroutines, and kuiklyx coroutine libraries. Use when executing background tasks, switching threads, or updating UI from async contexts. |
| [kuikly-assets-resource](skills/kuikly-assets-resource/SKILL.md) | Manages asset files and resource loading across platforms (Android, iOS, HarmonyOS, H5, Mini Programs). Use when adding local image resources or configuring asset bundling. |
| [kuikly-visibility-exposure](skills/kuikly-visibility-exposure/SKILL.md) | Implements visibility events (didAppear, didDisappear, willAppear, willDisappear, appearPercentage) for exposure tracking. Use when reporting component visibility or monitoring scroll-based exposure. |
| [kuikly-multi-module-config](skills/kuikly-multi-module-config/SKILL.md) | Configures multi-module Kuikly projects. Use when creating new Kuikly sub-modules, setting up multi-module parameters, or resolving KuiklyCoreEntry conflicts. |
| [kuikly-compose-interop-dsl](skills/kuikly-compose-interop-dsl/SKILL.md) | Integrates Kuikly DSL components within Compose DSL pages. Use when embedding DeclarativeBaseView/ViewContainer in Compose or calling Kuikly Modules from Compose. |
