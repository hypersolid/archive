function popitup(url) {
        W_Window=920
        H_Window=520
        leftPos = 0
        topPos = 0
        if (screen) {
        leftPos = (screen.width-W_Window) / 2
        topPos = (screen.height-H_Window) / 2
        }
        newwindow=window.open(url,'name','height='+H_Window+',width='+W_Window+',left='+leftPos+',top='+topPos);
        if (window.focus) {newwindow.focus()}
        return false;
}