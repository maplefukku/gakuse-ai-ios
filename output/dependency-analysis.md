# コンポーネント依存関係分析

## 生成日時
- 日時: $(date '+%Y-%m-%d %H:%M:%S')
- 分析対象: GakuseAI/Views/Components/*.swift

---

## 依存関係グラフ

```mermaid
graph TD
  AccordionView[AccordionView]
  ActionBar[ActionBar]
  AnimatedButton[AnimatedButton]
  AvatarGroup[AvatarGroup]
  AvatarView[AvatarView]
  BadgeView[BadgeView]
  BottomSheetView[BottomSheetView]
  BreadcrumbView[BreadcrumbView]
  CardView[CardView]
  CarouselView[CarouselView]
  CheckboxView[CheckboxView]
  Chips[Chips]
  ColorPickerView[ColorPickerView]
  DatePickerView[DatePickerView]
  DateTimePicker[DateTimePicker]
  DividerView[DividerView]
  EmptyStateView[EmptyStateView]
  ErrorView[ErrorView]
  FormView[FormView]
  GridView[GridView]
  LinearProgressView[LinearProgressView]
  ListView[ListView]
  LoadingView[LoadingView]
  MenuView[MenuView]
  ModalView[ModalView]
  NotificationCard[NotificationCard]
  OnboardingView[OnboardingView]
  PaginationView[PaginationView]
  ProfileCard[ProfileCard]
  ProgressRing[ProgressRing]
  PullToRefreshView[PullToRefreshView]
  QuickActionsView[QuickActionsView]
  RadioButtonView[RadioButtonView]
  RatingStar[RatingStar]
  RatingView[RatingView]
  SearchBar[SearchBar]
  SectionHeaderView[SectionHeaderView]
  SegmentedControl[SegmentedControl]
  SegmentedProgressView[SegmentedProgressView]
  SelectView[SelectView]
  SkeletonView[SkeletonView]
  Slider[Slider]
  SliderView[SliderView]
  SpinnerView[SpinnerView]
  StepperView[StepperView]
  SwipeActionView[SwipeActionView]
  TabBar[TabBar]
  TabView[TabView]
  TagView[TagView]
  TextInputField[TextInputField]
  TimelineView[TimelineView]
  Toast[Toast]
  ToastView[ToastView]
  ToggleSwitch[ToggleSwitch]
  TooltipView[TooltipView]
```

---

## コンポーネント一覧

| コンポーネント | 依存先 | 再利用性 |
|--------------|--------|----------|
| AccordionView | AccordionItemView(,AccordionView(,EmptyView(,SimpleAccordionView( | ★☆☆☆☆ |
| ActionBar |  | ★★★★★ |
| AnimatedButton |  | ★★★★★ |
| AvatarGroup |  | ★★★★★ |
| AvatarView | AvatarView( | ★★★★☆ |
| BadgeView | BadgeView( | ★★★★☆ |
| BottomSheetView | BottomSheetView(,SimpleBottomSheetView( | ★★★☆☆ |
| BreadcrumbView | BreadcrumbView(,ScrollView(,SimpleBreadcrumbView( | ★★☆☆☆ |
| CardView | CardView( | ★★★★☆ |
| CarouselView | CardCarouselView(,CarouselCardView(,CarouselItemView(,CarouselView(,ImageCarouselView(,ScrollView(,SimpleCarouselItemView(,SimpleCarouselView(,TabView( | ★☆☆☆☆ |
| CheckboxView | CheckboxGroupView(,CheckboxLabelView(,CheckboxView(,DividerView(,InteractiveView( | ★☆☆☆☆ |
| Chips | ScrollView( | ★★★★☆ |
| ColorPickerView | ColorPickerView(,CompactColorPickerView(,ScrollView( | ★★☆☆☆ |
| DatePickerView | DatePickerView(,DateRangePickerView( | ★★★☆☆ |
| DateTimePicker | ScrollView( | ★★★★☆ |
| DividerView | DividerView(,SectionDividerView(,VerticalDividerView( | ★★☆☆☆ |
| EmptyStateView | EmptyStateView( | ★★★★☆ |
| ErrorView | AuthenticationErrorView(,EmptyStateView(,ErrorView(,NetworkErrorView( | ★☆☆☆☆ |
| FormView | FormFieldView(,FormView(,GroupedFormView( | ★★☆☆☆ |
| GridView | AdaptiveGridView(,GridView(,MasonryGridView(,SimpleGridView( | ★☆☆☆☆ |
| LinearProgressView | LabeledLinearProgressView(,LinearProgressView(,MultiColorLinearProgressView(,SteppedLinearProgressView( | ★☆☆☆☆ |
| ListView | CardListView(,ListView( | ★★★☆☆ |
| LoadingView | ListSkeletonView(,LoadingView(,ProgressView(,SkeletonLoadingView( | ★☆☆☆☆ |
| MenuView | AnyView(,MenuView( | ★★★☆☆ |
| ModalView | AlertModalView(,AnyView(,ModalView(,SimpleModalView( | ★☆☆☆☆ |
| NotificationCard |  | ★★★★★ |
| OnboardingView | FeatureOnboardingView(,OnboardingPageView(,OnboardingView(,SimpleOnboardingView(,TabView( | ★☆☆☆☆ |
| PaginationView | InteractivePaginationView(,PaginationView(,SimplePaginationView( | ★★☆☆☆ |
| ProfileCard |  | ★★★★★ |
| ProgressRing |  | ★★★★★ |
| PullToRefreshView | AvatarView(,CardView(,CheckboxLabelView(,CustomView(,DividerView(,ListView(,MinimalView(,PullToRefreshView(,SimplePullToRefreshView(,SimpleView(,SpinnerView(,StandardView( | ★☆☆☆☆ |
| QuickActionsView | ActionButtonView(,QuickActionsView(,ScrollView( | ★★☆☆☆ |
| RadioButtonView | DividerView(,HorizontalView(,InteractiveView(,RadioButtonGroupView(,RadioButtonLabelView(,RadioButtonView(,VerticalView( | ★☆☆☆☆ |
| RatingStar | StarView( | ★★★★☆ |
| RatingView | EmojiRatingView(,HeartRatingView(,StarRatingView(,ThumbRatingView( | ★☆☆☆☆ |
| SearchBar |  | ★★★★★ |
| SectionHeaderView | ActionSectionHeaderView(,IconSectionHeaderView(,SectionHeaderView(,SimpleSectionHeaderView( | ★☆☆☆☆ |
| SegmentedControl |  | ★★★★★ |
| SegmentedProgressView | HorizontalSegmentedProgressView(,SegmentedProgressView( | ★★★☆☆ |
| SelectView | CardSelectView(,DropdownSelectView(,RadioSelectView(,ScrollView(,SelectView( | ★☆☆☆☆ |
| SkeletonView | SkeletonView( | ★★★★☆ |
| Slider |  | ★★★★★ |
| SliderView | DividerView(,InteractiveView(,LabeledSliderView(,RangeSliderView(,SliderView( | ★☆☆☆☆ |
| SpinnerView | BarSpinnerView(,DividerView(,DotsSpinnerView(,PulseSpinnerView(,SpinnerView( | ★☆☆☆☆ |
| StepperView | SimpleStepperView(,StepperView( | ★★★☆☆ |
| SwipeActionView | SwipeActionView( | ★★★★☆ |
| TabBar | BottomNavigationView( | ★★★★☆ |
| TabView | AnyView(,EmptyView(,SimpleTabView(,TabView( | ★☆☆☆☆ |
| TagView | TagGroupView(,TagView( | ★★★☆☆ |
| TextInputField |  | ★★★★★ |
| TimelineView | ActivityItemView(,ActivityTimelineView(,ProgressStepView(,ProgressTimelineView(,SimpleTimelineView(,TimelineItemView(,TimelineView( | ★☆☆☆☆ |
| Toast |  | ★★★★★ |
| ToastView | SimpleToastView(,ToastContainerView(,ToastView( | ★★☆☆☆ |
| ToggleSwitch |  | ★★★★★ |
| TooltipView | TooltipView( | ★★★★☆ |
