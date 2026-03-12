#!/bin/bash

components=(
    "AnimatedButton"
    "AvatarGroup"
    "BadgeView"
    "BreadcrumbView"
    "CardView"
    "CheckboxView"
    "ChipView"
    "DatePickerView"
    "EmptyStateView"
    "ErrorView"
    "FormView"
    "GridView"
    "LinearProgressView"
    "ModalView"
    "ProgressRing"
    "QuickActionsView"
    "RadioButtonView"
    "RatingStar"
    "SearchBar"
    "SectionHeaderView"
    "SegmentedControl"
    "SegmentedProgressView"
    "SelectView"
    "SliderView"
    "SpinnerView"
    "StepperView"
    "TabBar"
    "TextInputField"
    "TimePickerView"
    "Toast"
    "ToggleSwitch"
)

for component in "${components[@]}"; do
    count=$(grep -r "$component" GakuseAI/Views --include="*.swift" | grep -v "Components/$component.swift" | grep -v "Preview" | wc -l | tr -d ' ')
    if [ "$count" = "0" ]; then
        echo "$component: $count"
    fi
done
