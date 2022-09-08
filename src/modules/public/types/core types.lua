---> @Section Core
export type Array<T> = {
    [number] : T
}

export type Pair<T> = {
    first : T,
    second : T
}

export type FriendlyPair<T, P> = {
    first : T,
    second : P
}

export type logger = {
    Context : string
}

---> @Section User interface

export type PagePair = FriendlyPair<UIButton, GuiObject>;

export type UIButton = {
    Parent : GuiMain?,
    Object : GuiButton?,
    Connections : Array<RBXScriptConnection>,

    registerOnClick : (self : UIButton, func : () -> (), name : string?) -> (),
    destroy : (self : UIButton) -> (),
    destroyKnownConnection : (self : UIButton, name : string) -> (),
    new : (self : UIButton, button : GuiMain, buttonType : number?) -> UIButton
}

export type UIText = {
    Parent : GuiMain?,
    Object : TextLabel?,
    Connections : Array<RBXScriptConnection>,

    get : (self : UIText) -> string,
    set : (self : UIText, what : string) -> (),
    destroyKnownConnection : (self : UIText, name : string) -> (),
    new : (self : UIText, button : GuiMain, labelType : number?) -> UIText
}


export type UIPages = {
    Connections : Array<RBXScriptConnection>,

    new : (self : UIPages, pageGroup : Array<PagePair>, OnReplace : (PagePair) -> (), OnNew : (PagePair) -> ()) -> UIPages,
    newPage : (self : UIPages, page : PagePair) -> (),
    processPage : (self : UIPages, page : PagePair) -> (),
    setMainPage : (self : UIPages, page : PagePair) -> boolean,
    setupLiseners : (self : UIPages) -> UIPages,
}

return nil