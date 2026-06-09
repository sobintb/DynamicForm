# Dynamic Form - A Server-Driven UI Dynamic Form

A SwiftUI application that dynamically renders forms from a server-provided JSON schema. Form fields, validation rules, ordering, and visual styling are all controlled by the backend, allowing form updates without requiring app releases.

## Tech Stack

* **Architecture:** MVVM
* **UI Framework:** SwiftUI
* **Language:** Swift
* **State Management:** ObservableObject, EnvironmentObject
* **Data Parsing:** JSONDecoder

## Architecture

The application follows a clean MVVM architecture:

* **Decode Layer** – Parses the JSON schema and theme using `JSONDecoder`.
* **Model Layer** – Uses a polymorphic `FormField` enum to support multiple field types such as text inputs, dropdowns, toggles, and checkboxes.
* **State Layer** – `FormViewModel` manages form values, selections, and validation errors.
* **View Layer** – SwiftUI views are generated dynamically based on the decoded schema.

## Key Features

* Dynamic form rendering from server-defined JSON
* Server-driven theming and styling
* Built-in field validation support
* Forward-compatible handling of unknown field types
* Centralized state management with MVVM




# Product Decisions

1. **Handling Missing Data**
   Most missing fields were handled using optional values. Empty text fields are displayed as blank, and dropdowns with missing or empty options are still shown but allow an empty selection without triggering errors.

2. **Default Value vs. Max Length**
   The provided sample data contained default values that exceeded the configured max length. In such cases, I ignored the default value and displayed an empty text field to maintain a valid state.

3. **Validation Timing**
   Validation runs both during input and on form submission. Required-field errors update live, while max-length enforcement currently trims the text after editing due to limitations in the current binding implementation.

4. **Navigation Title Styling**
   The form title was initially implemented using the iOS large navigation title style, which visually complemented the form. However, automatic theme-based text color rendering did not work consistently with the large title. To ensure proper theme support and a consistent user experience, I switched to the standard navigation title style.

5. **Theme Color Fallbacks**
   If a color value is missing from the JSON or a hex color cannot be decoded correctly, the app automatically falls back to a suitable default color. This prevents UI rendering issues and ensures the form remains usable even when theme data is incomplete or invalid.

6. **Theme-Aware UI Styling**
   To improve visual consistency, I added custom styling for active text fields, placeholder text, and character count indicators. These colors are automatically derived from the rendered theme to maintain readability and provide a better user experience across different theme configurations.

    
## Improvements

1. **Better Edge Case Handling**
   Some edge cases, such as dropdowns with missing options and default text values exceeding max-length limits, are currently handled with pragmatic fallback logic to avoid workflow interruptions. With more time, I would refine these behaviors based on the exact product requirements.

2. **Improved Theme Support**
   The large navigation title was removed due to text color issues caused by dynamic theme rendering. Given more time, I would explore a more robust theming approach, such as adapting the interface style based on background colors, to retain the large title while maintaining proper contrast and readability.

3. **Graceful Theme Fallbacks**
   The app currently expects the `theme` object to be present in the JSON. I would make theme parsing optional and provide a default theme configuration so that the form can still render correctly even when theme data is missing.

4. **Loading and Error States**
   The current implementation focuses on rendering the form from local JSON data and does not include dedicated loading, success, or failure states. If the form configuration were fetched from a network source, I would add proper state management and user feedback for loading and error scenarios to improve the overall user experience.


## Challenges

1. **Live Validation with Custom Bindings**
   The main challenge I faced was implementing live max-length validation while using custom bindings. With standard SwiftUI bindings, restricting input beyond a character limit is straightforward, but the custom binding approach used in this project behaved differently. I was able to implement all required validations and enforce the limit after editing, but fully preventing additional input during typing would require further investigation.

2. **Learning SDUI Concepts**
   I had limited experience with Server-Driven UI (SDUI), so understanding the dynamic data flow and rendering process took additional time. I worked through it by researching the concepts and using available learning resources and AI-assisted guidance.

3. **Navigation Title Styling**
   Another challenge was styling the iOS large navigation title to work correctly with dynamically configured theme colors. I explored several approaches to apply custom colors, but the results were inconsistent. Given the time constraints, I chose a simpler and more reliable solution by replacing the large title with a standard navigation title, which supports the required theme colors with minimal modifications and provides a consistent user experience.

