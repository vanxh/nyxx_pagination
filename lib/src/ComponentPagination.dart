part of nyxx_pagination;

/// Base component paginator. If don't want custom behavior on page update use [ComponentPagination].
abstract class IComponentPagination extends IPagination<ButtonInteractionEvent, ComponentMessageBuilder> {
  /// Reference to [Interactions]
  final Interactions interactions;
  /// Custom id for this instance of paginator that different paginators could be recognized.
  late final String customPreId;

  late ComponentMessageBuilder _builder;

  /// Creates new paginator using interactions
  IComponentPagination(this.interactions) {
    this.customPreId = randomAlpha(5);
  }

  /// Inits [ComponentMessageBuilder] with buttons needed for pagination. And hooks needed events.
  @override
  ComponentMessageBuilder initMessageBuilder() {
    final firstPageButtonId = "${customPreId}firstPage";
    final firstPageButton = ButtonBuilder("<<", firstPageButtonId, ComponentStyle.secondary);
    interactions.onButtonEvent.where((event) => event.interaction.customId == firstPageButtonId).listen((event) async {
      await event.acknowledge();

      this.onFirstPageButtonClicked();
      updatePage(this.currentPage, this._builder, event);
    });

    final previousPageButtonId = "${customPreId}previousPage";
    final previousPageButton = ButtonBuilder("<", previousPageButtonId, ComponentStyle.secondary);
    interactions.onButtonEvent.where((event) => event.interaction.customId == previousPageButtonId).listen((event) async {
      await event.acknowledge();

      this.onPreviousPageButtonClicked();
      updatePage(this.currentPage, this._builder, event);
    });

    final nextPageButtonId = "${customPreId}nextPage";
    final nextPageButton = ButtonBuilder(">", nextPageButtonId, ComponentStyle.secondary);
    interactions.onButtonEvent.where((event) => event.interaction.customId == nextPageButtonId).listen((event) async {
      await event.acknowledge();

      this.onNextPageButtonClicked();
      updatePage(this.currentPage, this._builder, event);
    });

    final lastPageButtonId = "${customPreId}lastPage";
    final lastPageButton = ButtonBuilder(">>", lastPageButtonId, ComponentStyle.secondary);
    interactions.onButtonEvent.where((event) => event.interaction.customId == lastPageButtonId).listen((event) async {
      await event.acknowledge();

      this.onLastPageButtonClicked();
      updatePage(this.currentPage, this._builder, event);
    });

    this._builder = ComponentMessageBuilder()
      ..components = [
        [
          firstPageButton,
          previousPageButton,
          nextPageButton,
          lastPageButton,
        ]
      ];

    return this.getMessageBuilderForPage(1, this._builder);
  }
}

/// Base class for custom interaction paginator.
/// [getMessageBuilderForPage] needs to be implemented in order to work.
abstract class ComponentPagination extends IComponentPagination {
  /// Creates instance of [ComponentPagination]
  ComponentPagination(Interactions interactions): super(interactions);

  @override
  FutureOr<void> updatePage(int page, ComponentMessageBuilder currentBuilder, ButtonInteractionEvent target) {
    target.respond(this.getMessageBuilderForPage(page, currentBuilder));
  }
}

/// Paginator where each page is embed
class EmbedComponentPagination extends ComponentPagination {
  @override
  int get maxPage => this.embeds.length;

  /// List of embeds to paginate with
  final List<EmbedBuilder> embeds;

  /// Creates instance of [EmbedComponentPagination]
  EmbedComponentPagination(Interactions interactions, this.embeds): super(interactions);

  @override
  ComponentMessageBuilder getMessageBuilderForPage(int page, ComponentMessageBuilder currentBuilder) =>
      currentBuilder..embeds = [embeds[page - 1]];
}

/// Paginator where each page is message content
class SimpleComponentPagination extends ComponentPagination {
  @override
  int get maxPage => this.contentPages.length;

  /// List of string to paginate with
  final List<String> contentPages;

  /// Creates instance of [SimpleComponentPagination]
  SimpleComponentPagination(Interactions interactions, this.contentPages): super(interactions);

  @override
  ComponentMessageBuilder getMessageBuilderForPage(int page, ComponentMessageBuilder currentBuilder) =>
      currentBuilder..content = contentPages[page - 1];
}
