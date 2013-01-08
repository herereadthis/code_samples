do ( jQuery ) ->
    $ = jQuery

    settings =
        directSection: "#data_direct"
        hierarchySectionID: "data_hierarchy"
        hierarchySection: ""
        # ID for the <UL> that makes the listing for the main section
        # shares with file_ballet.coffee
        listingID: "list_current"
        # comments that say, "this hierarchy has ### children," where ### is wrapped in this class
        listCountClass: "list_count"
        expandAll: ".expand_all"
        expandFlyout: ".expand_flyout"
        flyoutComplete: "flyout_complete"
        # the top padding of each flyout menu
        flyoutTopPad: 10
        # the top positioning of each flyout menu
        flyoutTopPos: -10
        stackMenu: "#stack_menu"
        stackFlyoutClass: "stack_flyout"
        # long titles will make for stack menu items that go into multiple lines of text.
        # after this cutoff, text will be truncated, with an ellipsis added.
        stackLineLimit: 5
        stackLineHeight: 16
        loadOptions:
            id: 0
            hierarchy: ""
        stacksMetaData:
        	journal:
        		# "BIB ID":
        		# 	"type":"text"
        		# 	"data":"ils_bib_id"
        		"ISSN":
        			"type":"link"
        			"data":"issn"
        			"link":"ils_url"
        		"Publisher":
        			"type":"api"
        			"data":"publishers"
        			"apiData":"title"
        fileListing: ["pdf","html","htm","xml"]
        fileExclude: ["zip"]
        fileListText: "Quick view"
        fileQuickViewID: "quick_view"
        # class for comment informing the user that irregular traversing has occurred,
        # e.g., an issue that has no articles but many files
        traverseClass: "level_traverse"
        traverse: ""
        # class for comment informing the user that the current object has orphans at some specific level
        orphanCommentClass: "level_orphan"
        # variables that determine the behavior of the ajax loading gif
        ajaxLoad:
            id: "#ajax_load"
            aniSpeed: 100
            # expressed as ems
            height: 3.1


    globalVars = 
        # used by methods.getParentID. Since the parentID is found via ajax, the varaible must be passed to a global
        parentID: 12
        hierarchyTitle: ""
        # used to store a parent title
        parentTitle: ""
        fileListing: []
        # used to store any title
        linkTitle: ""
        # used to store options during traversal
        stackOpts:
            id: 0
            hierarchy: ""
        # classes made from settings
        orphanComment: ""
        listCount: ""


    methods = 
        init: ( options ) ->
            this.each () ->
                $.extend(settings, options)
                $this = $ @
                # # leave this here for testing.
                # console.log "init ajaxCalls"

                # set the class for traversing comments
                settings.traverse = ".#{ settings.traverseClass }"
                # set the class for orphan comments
                globalVars.orphanComment = ".#{ settings.orphanCommentClass }"
                # set the ID of the section that lists hierarchies
                settings.hierarchySection = "##{ settings.hierarchySectionID }"
                # set the class for the count of children for each hierarchy listing
                globalVars.listCount = ".#{ settings.listCountClass }"

                # # Revisit when there are canonical pages for volumes, issues, articles, etc

                # # Draft 1: the following is the intended result for a journals' page.
                # methods.journalAjax $(settings.hierarchySection),settings.loadOptions

                # # Draft 2: on load, the page doesn't know on which level of hierarchy it is.
                # # use the hierarchy to build the correct  ajax call
                # # onLoadAjaxCall = "#{ settings.loadOptions.hierarchy }Ajax"
                # methods[onLoadAjaxCall] $(settings.hierarchySection),settings.loadOptions

                # Draft 3: hierarchy-expanded API response allows for an AJAX call blind
                # that is, it is an ajax call that does not require query parameters
                # "given this id and hierarchy, find all its children" vs.
                # "find all objects, and filter by those which are children of this id"
                if settings.loadOptions.id? and settings.loadOptions.hierarchy?
                    methods.canonicalAjax $(settings.hierarchySection),settings.loadOptions

                # click function for any link that loads a canonical page
                $this.on "click",".view_more_info", (e) ->
                    e.preventDefault()
                    options =
                        id: $(@).attr "data-id"
                        hierarchy: $(@).attr "data-hierarchy"
                    # revised version takes options.hierarchy and determines children
                    methods.canonicalAjax $(settings.hierarchySection),options
                    # preserving the older version of children filtered by parent ID
                    # ajaxCall = "#{ options.hierarchy }Ajax"
                    # methods[ajaxCall] $(settings.hierarchySection),options

                # click function for any link that appears in a flyout from the stack menu
                $(settings.stackMenu).on "click",".expand_list", (e) ->
                    e.preventDefault()
                    options =
                        id: $(@).attr "data-id"
                        hierarchy: $(@).attr "data-hierarchy"
                    # revised version takes options.hierarchy and determines children
                    methods.canonicalAjax $(settings.hierarchySection),options
                    # preserving the older version of children filtered by parent ID
                    # ajaxCall = "#{ options.hierarchy }Ajax"
                    # methods[ajaxCall] $(settings.hierarchySection),options

                # click function that will expand a level and surface all of its children as a dropdown
                $(settings.hierarchySection).on "click",".expand_list", (e) ->
                    e.preventDefault()
                    options =
                        id: $(@).attr "data-id"
                        hierarchy: $(@).attr "data-hierarchy"
                    # # since we start at the journal level, there is no need to expand a listing from a publisher
                    # if options.hierarchy is "volume" or options.hierarchy is "issue"
                    #     ajaxCall = "#{ options.hierarchy }ExpandAjax"
                    #     methods[ajaxCall] $(@),options
                    # # articles are the exception. They just straigt to a canonical page
                    # if options.hierarchy is "article"
                    #     ajaxCall = "#{ options.hierarchy }Ajax"
                    #     methods[ajaxCall] $(settings.hierarchySection),options

                    # revisition! all hierarchies expand unless no child exists
                    if methods.getChild(options.hierarchy)?
                        # revised version takes options.hierarchy and determines children
                        methods.listExpandAjax $(@),options
                        # preserving the older version of children filtered by parent ID
                        # ajaxCall = "#{ options.hierarchy }ExpandAjax"
                        # methods[ajaxCall] $(@),options

                    if !$(@).hasClass "selected"
                        $(@).addClass "selected"
                    else
                        $(@).removeClass "selected"

                # click function that creates a flyout menu generated by stacks menu
                $this.on "click",settings.expandFlyout, (e) ->
                    e.preventDefault()
                    # get height of the link, so that the styling for elements in the flyout appear correct
                    # different heights are based on the line heights of the links plus padding
                    # one line is 16px line height + 2 X 7 top and bottom padding = 30
                    baseHeight = 14
                    # therefore, 2 lines is 30 + 16 = 46
                    # 3 lines is 30 + 16 + 16 = 62
                    lineHeight = settings.stackLineHeight
                    # go minus 2 for rounding errors due to line-height miscalcultions
                    linkHeight = $(@).outerHeight()
                    stackLimitHeight = baseHeight + lineHeight * settings.stackLineLimit
                    lineCount = (linkHeight - baseHeight) / lineHeight

                    # adding classes to flyouts - only matters when stack menu link is 2 or more lines
                    classToAdd = "flyout_#{ lineCount }line"
                    $(@).addClass classToAdd
                    
                    # THE FOLLOWING IS FOR TRUNCATING LONG STACK MENU ITEMS. DEVELOP LATER!
                    # if stackLimitHeight < linkHeight
                    #     textTrail = ""
                    #     while stackLimitHeight < linkHeight
                    #         textTruncate = $(@).text()
                    #         textTruncate = textTruncate.split(" ").slice(0,-1).join(" ")
                    #         $(@).html(textTruncate)
                    #         linkHeight = $(@).outerHeight()

                    options =
                        id: $(@).attr "data-id"
                        hierarchy: $(@).attr "data-hierarchy"
                    if methods.getChild(options.hierarchy)?
                        # revised version takes options.hierarchy and determines children
                        methods.flyoutAjax $(this),options
                        # preserving the older version of children filtered by parent ID
                        # ajaxCall = "#{ options.hierarchy }FlyoutAjax"
                        # methods[ajaxCall] $(this),options
                        if !$(@).parent().hasClass "selected"
                            $(settings.stackMenu).children(".selected").removeClass "selected"
                            $(@).parent().addClass "selected"
                        else
                            $(@).parent().removeClass "selected"

                # click function that will expand all lists for children.
                # Kind of like methods.makeExpandList on steroids.
                $(settings.hierarchySection).on "click",settings.expandAll, (e) ->
                    e.preventDefault();
                    listTitle = $(@).closest(settings.hierarchySection).find(".list_title")
                    # option to collapse all lists means clicking on "expand all" changes state to "selected"
                    if !$(@).hasClass "selected"
                        $(@).addClass "selected"
                        $(@).html "collapse all"

                        options =
                            id: $(@).attr "data-id"
                            hierarchy: $(@).attr "data-hierarchy"
                        if options.hierarchy != "article"
                            $(listTitle).children("li").each (i) ->
                                childLink = $(@).children("a")
                                childOptions = 
                                    id: childLink.attr "data-id"
                                    hierarchy: childLink.attr "data-hierarchy"
                                if !childLink.hasClass "selected"
                                    childLink.addClass "selected"
                                if childOptions.hierarchy is "volume" or childOptions.hierarchy is "issue" or childOptions.hierarchy is "article"
                                    # revised version takes options.hierarchy and determines children
                                    methods.listExpandAjax childLink,childOptions
                                    # preserving the older version of children filtered by parent ID
                                    # ajaxCall = "#{ childOptions.hierarchy }ExpandAjax"
                                    # methods[ajaxCall] childLink,childOptions
                    else
                        $(@).removeClass "selected"
                        $(@).html "expand all"
                        # notice that it's .find("a") and not .children("a"), which means all tiers are collapsed
                        # acts like a reset, though since ajax calls have been made, nothing is deleted from DOM
                        # class ".selected" is what triggers visibility, not deletion of elements
                        childLink = $(listTitle).children("li").find("a").removeClass "selected"

                # click function that hide flyouts if user clicks on anywhere but the flyout itself
                $this.on "click", (event) ->
                    _target = $(event.target)
                    stackFlyoutClass = settings.stackFlyoutClass
                    stackFlyout = ".#{ stackFlyoutClass }"
                    if !_target.closest(stackFlyout).length and !_target.siblings().hasClass stackFlyoutClass
                        $(stackFlyout).parent().removeClass "selected"
                
                # click function to load new stack menu when user clicks to view files.
                # new stack menu will remove itself with methods.shutdown() from the file_ballet.js
                $this.on "click", ".view_file", (event) ->
                    event.preventDefault()
                    options = 
                        id: $(@).attr "data-id"
                        hierarchy: $(@).attr "data-hierarchy"
                    # build the stacks menu
                    methods.makeStacks options

                    


        checkExpandAll: () ->
            _this = $(settings.expandAll)
            if !_this.hasClass "selected"
                # do nothing for now
            else
                _this.removeClass "selected"
                _this.html "expand all"


        # see if object is in an array
        checkInArray: (obj,array) ->
            # set initially: the fileType is not an image
            objExists = false
            for i,k in array
                if i == obj
                    # fileType matched one of the image
                    # there is no "else" in this for loop. Sets to true if exists, otherwise remains false
                    objExists = true
            objFound = if objExists then true else false
            objFound


        # returns object, sorted by data.objects.file_path
        # mostly used during the process of getting files from an AJAX response
        getFilePathSort: (a,b) ->
            # the following is ideal, but will not work in ie8
            # a.file_path < b.file_path
            # ie8 solution means don't use the same variables as part of the return.
            # http://www.zachleat.com/web/array-sort/
            x = a.file_path
            y = b.file_path
            return 1 if x < y
            return -1 if x > y

        
        # returns the child of the given hierarchy level.
        getChild: (hierarchy) ->
        	if hierarchy is "journal"
        		child = "volume"
        	else if hierarchy is "volume"
        		child = "issue"
        	else if hierarchy is "issue"
        		child = "article"
        	else if hierarchy is "article"
        		child = "file"
        	child


        # method to reduce count of listing by one
        # the logic here is that when a comment is made for a listing,
        # e.g., "This journal has 40 volumes" e.g., "This issue has 13 orphan files"
        # the original count is pull from finding array.length in JSON response
        # since some of the files will be excluded, e.g., .ZIP, or directories,
        # the count has to be reduced by 1
        getListCut: ( _ulClass ) ->
            # methods.makeOrphanList has made a <p> before this ulClass, listing file count
            # same goes for methods.makeTitleList
            _listCount = _ulClass.prev("p").find(globalVars.listCount)
            # extract the file count
            listCount =  parseInt _listCount.html(),10
            # since entry was null, reduce count by one.
            listCount--
            _listCount.html listCount


        # regex to get file extension.
        # pattern from Stack Overflow http://stackoverflow.com/questions/6582171/
        getFileExtension: ( filename ) ->
            # ext = /^.+\.([^.]+)$/.exec filename
            filePattern = /\.([0-9a-z]+)(?:[\?#]|$)/i
            ext = filename.match filePattern
            # ext is an array, where ext[1]. if exists is the file type
            extension = if ext is null then null else ext[1]
            extension

        # returns the parent of the given hierarchy level.
        getParent: (hierarchy) ->
        	switch hierarchy
                when "file" then parent = "article"
                when "article" then parent = "issue"
                when "issue" then parent = "volume"
                when "volume" then parent = "journal"
            parent


        getParentID: (options) ->
            # currentParentID = globalVars.parentID
            parent = methods.getParent options.hierarchy
            $.ajax
                url: "/api/v1/stacks/#{ options.hierarchy }/#{ options.id }/"
                dataType: "json"
                async: false
                data:
                    format: "json"
                success: (data) ->
                    if data[parent] != undefined
                        parentURL = data[parent]
                        # the ID of the parent comes from the data about the parent, expressed as a resource URI
                        # parentUrlSplit = parentURL.split("#{ parent }/")
                    # else typically case means we've arrived an entry that belongs to multiple ancesters
                    # typically occurs only at file level, and always occurs at file level
                    # will spit out an array instead of a string
                    else
                        # that is, if the current hierarchy has a parent, but that parent has no data
                        # in other words, a file that doesn't belong to an article but does belong to an issue
                        # or an article that doesn't belong to volume, but does belong to a journal
                        if data["#{ parent }s"].length is 0
                            ancestor = parent
                            # traverse up the current hierarchy's ancesters until there is an ancester with data
                            while data["#{ ancestor }s"].length is 0
                                ancestor = methods.getParent ancestor
                            parentUrlArray = data["#{ ancestor }s"]
                            # now set the ancester level to global Variables
                            # However, the looping of methods.makeStacks will go up one level too far,
                            # so get child of ancester.
                            globalVars.stackOpts.hierarchy = methods.getChild ancestor
                            # since hierachy has been skipped, treat ancester as parent
                            parent = ancestor
                        # else is ideal situation: the current hierarchy has a parent, and that parent has data.
                        else
                            parentUrlArray = data["#{ parent }s"]
                        # assume last in arry is the actual parent resource URI
                        parentURL = parentUrlArray[parentUrlArray.length - 1]

                    # the structure of the resource URI gives the ID of the parent as part of the URI
                    parentUrlSplit = parentURL.split("#{ parent }/")
                    # e.g. split of "/api/v1/stacks/PARENT/#####/"
                    parentID = parseInt parentUrlSplit[1]
                    globalVars.parentID = parentID

            # returns the parent ID
            globalVars.parentID


        # finds the link of the file, if the current hierarchy is indeed the last, aka file
        getFileData: (data) ->
            filePath = data.file_path
            # old version is a split then take last.
            # fileTypeSplit = filePath.split "."
            # fileType = "#{ fileTypeSplit[-1..] }"
            # regex for the fileType
            fileType = methods.getFileExtension filePath
            # transform url is for XML transforms using xslt
            if fileType is "xml"
                getURL = data.stacks_get_transform_url
            # proxy url for everything else
            else
                getURL = data.stacks_get_absolute_url
            # returns options only if the file is indeed a file
            if fileType?
                options = 
                    href: getURL
                    # file extension is lower-cased. So that string matching for .JPG matches .jpg
                    fileType: fileType.toLowerCase()
                options
            # if it's not a file return nothing.
            else
                null


        # makes a text comment explaining to user how many orphans of a particular hierarchy the object has
        makeOrphanComment: ( options, ODL, descendant ) ->
            orphanComment = "This #{ options.hierarchy } has "
            orphanComment += "<strong class=\"#{ settings.listCountClass }\">#{ ODL }</strong> orphaned #{ descendant }"
            if ODL > 1
                orphanComment += "s. They do not belong to any "
            else 
                orphanComment += ". It does not belong to any "
            # knownAncestor = options.hierarchy
            # while loop explicitly states which types of ancestor hierarchies have no relation with the orphan
            orphanAncestor = methods.getParent descendant
            orphanChain = 1
            # It works by finding what a theoretical parent of the orphan is,
            # and if that parent can be a descendant of the orginal hierarchy.
            while orphanAncestor != options.hierarchy
                # if the next parent is the original hierachy, terminate the comment with a period.
                if methods.getParent(orphanAncestor) == options.hierarchy
                    # that is if there is only a gap of one between the orphan and the original hierachy.
                    # E.g. an orphan article of a volume only has one gap
                    if orphanChain is 1
                        orphanComment += "#{ orphanAncestor }s."
                    # multiple gaps, e.g, orphaned file of a volume
                    else 
                        orphanComment += "or #{ orphanAncestor }s."
                # else means there are multiple gaps but the while loop has not reached the end.
                else
                    # i.e. if and only if there are two gaps and the next level up is not the original hierarchy
                    # E.g. ..."do not belong to any *articles* or issues." Note *article* does not need a comma
                    if orphanChain is 1 and methods.getParent(methods.getParent(orphanAncestor)) == options.hierarchy
                        orphanComment += "#{ orphanAncestor }s "
                    # else here is the default action is to add commas and continue.
                    # E.g. ..."do not belong to any *articles,* or issues." Comma after *articles*
                    else 
                        orphanComment += "#{ orphanAncestor }s, "
                orphanAncestor = methods.getParent orphanAncestor
                orphanChain++
            orphanComment

        # creates an unordered list with a heading to begin dumping of orphans
        makeOrphanList: ( _this, options, descendant, orphanData ) ->
            # ODL = orphanData.length
            ODL = orphanData.length
            # # call for orphans comes from multiple sources!
            makeUL = "list_orphan_#{ descendant }s_#{ options.hierarchy }_#{ options.id }"
            ulClass = ".#{ makeUL }"
            _this.append $("<ul />").addClass(makeUL).addClass "list_#{ options.hierarchy }"
            orphanComment = methods.makeOrphanComment options,ODL,descendant
            # A comment giving the status of orphans is given before the listing of orphans
            $(ulClass).before $("<p />").html(orphanComment).addClass settings.orphanCommentClass
            # quick view may be necessary, but seems more relevant for files in proper hierarchies
            # methods.makeFileView _this,options,orphanData
            ulClass


        # methods to find all orphans of a given hierarchy. Used by canonicalAjax() and listExpandAjax()
        # uses methods.makeOrphanList to build each list.
        # That is, a given hierarchy can have orphans at multiple descendent levels.
        makeOrphanLoop: ( _this, options, data ) ->
            # note that the hunt for orphans is not dependent on whether the object has children
            # that is, any object can have only children, or can have only orphans, 
            # or can have both children and orphans
            descendant = methods.getChild options.hierarchy
            # a check for grandchilden prevents articles from listing files as their own orphans.
            grandChild = methods.getChild descendant

            # only loop through possible orphans if the descendant is possible and the descendant can have children.
            # E.g. will not loop for files because files cannot have children.
            while descendant? and grandChild?
                # E.g. data.orphan_articles
                orphanData = data["orphan_#{ descendant }s"]
                # That is, only build list if orphan data exists
                if orphanData != undefined
                    # and the array for orphan data has at least one entry
                    if orphanData.length > 0
                        ulClass = methods.makeOrphanList _this, options, descendant, orphanData
                        if !methods.getChild(descendant)?
                            # create a new object from data.objects, where data.objects are sorted by file path
                            orphanData = orphanData.sort methods.getFilePathSort
                        for i in orphanData
                            entry = methods.makeDropdownLI i, options, descendant
                            # that is, an attempt to make a new list item from children did not return null
                            if entry?
                                $(ulClass).prepend entry 
                            else
                                # trim the list count by one
                                methods.getListCut $(ulClass)
                descendant = methods.getChild descendant


        # hide or show the ajax loading animated gif
        # swiped from file_ballet.coffee. Check there for additional comments
        makeAjaxLoad: () ->
            alHeight = globalVars.getEm * settings.ajaxLoad.height * -1
            al = $(settings.ajaxLoad.id)
            if al.hasClass "selected"
                al.removeClass("selected").fadeOut settings.ajaxLoad.aniSpeed
            else
                al.show().addClass "selected"


        # makes a dropdown list of children.
        # This method is universal and applies to all AJAX methods that look for children.
        # Specific case for ophan hunting will give descendant variable.
        makeDropdownLI: (i, options, descendant) ->
            descendant = descendant or null
            if descendant?
                child = descendant
            else
                child = methods.getChild options.hierarchy
            theLevel = "level_#{ child }"
            if i.title
                listText = i.title
            else if i.file_path
                listText = i.file_path
            else if i.resource_uri
                listText = i.resource_uri
            else if i.attributes.title
                listText = i.attributes.title
            else
                listText = i.id
            grandChild = methods.getChild child or null
            if grandChild?
                listLink = $("<a />").html(listText).attr
                    "href": ""
                    "class": "expand_list"
                    "data-hierarchy": child
                    "data-id": i.id
                    "data-foo": "foo"
                spanLink = $("<a />").html("Go to #{ child }").attr
                    "href":""
                    "class":"show_#{ child }_#{ i.id } view_more_info"
                    "data-hierarchy": child
                    "data-id": i.id
                listSpan = $("<span />").html " | "
                listSpan.append spanLink
                theList = $("<li />").addClass(theLevel).append(listLink)
                theList = theList.append(listSpan)
                theList
            else
                # basically this is for files.
                fileOptions = methods.getFileData i
                # if fileOptions.fileType?
                    # console.log fileOptions.fileType
                # console.log fileOptions
                if fileOptions?
                    # if the type of file is not excluded from the set of fileTypes to exclude
                    if methods.checkInArray(fileOptions.fileType, settings.fileExclude) is false
                        listLink = $("<a />").html(listText).attr
                            "href": fileOptions.href
                            # note that a view_more_info class is added. Will triger methods.fileAjax from within init.
                            "class": "view_#{ child } view_more_info"
                            "data-hierarchy": child
                            "data-id": i.id
                            "data-file-type": fileOptions.fileType
                        theList = $("<li />").addClass(theLevel).append(listLink)
                        theList
                    # return null if fileType matches exclusion list
                    else
                        null
                # return null if object has no file Type
                else
                    null
    

        # used excluslively by methods.makeMetaData.
        # The ajax is done in a separate method because the call to make it can be from an array or a string.
        makeMetaDataAjax: (_this,metaWord,dataObject,apiData) ->
            $.ajax
                url: dataObject
                dataType: "json"
                data:
                    format: "json"
                success: (data) ->
                    globalVars.parentTitle = data[apiData]
                    valueText = "#{ metaWord }:  <span>#{ globalVars.parentTitle }</span>"
                    _this.find("ul").append $("<li />").addClass("meta_#{ metaWord.toLowerCase() }").html valueText


        makeMetaData: (_this,options,data) ->
            makeUL = "stack_meta_#{ options.hierarchy }_#{ options.id }"
            ULID = "##{ makeUL }"
            # List comprehension in CoffeeScript Awesome!
            for own key, valueHierarchy of settings.stacksMetaData
                if options.hierarchy is key
                    _this.append $("<ul />").attr("id",ULID)
                    for own key, value of valueHierarchy
                        if value.type is "text"
                            _this.find("ul").append $("<li />").html("#{ key }:  <span>#{ data[value.data] }</span>")
                        if value.type is "link"
                            valueLink = $("<a />").html("#{ data[value.data] }").attr
                                href: data[value.link]
                            _this.find("ul").append $("<li />").html("#{ key }: ").append valueLink
                        if value.type is "api"
                            if typeof data[value.data] != "string"
                                for i in data[value.data]
                                    methods.makeMetaDataAjax _this,key,data[value.data],value.apiData
                            else
                                methods.makeMetaDataAjax _this,key,data[value.data],value.apiData


        makeStacks: (options) ->
            parent = methods.getParent options.hierarchy
            stackMenu = $(settings.stackMenu)
            stackMenu.empty()
            globalVars.stackOpts =
                id: options.id
                hierarchy: options.hierarchy
            while globalVars.stackOpts.hierarchy
                $.ajax
                    url: "/api/v1/stacks/#{ globalVars.stackOpts.hierarchy  }/#{ globalVars.stackOpts.id }/"
                    dataType: "json"
                    async: false
                    data:
                        format: "json"
                    success: (data) ->
                        # files will not have a title, or rather,
                        # the title is buried in data.attributes as part of a string
                        # to protect uniformity instead of writing exceptions, the fallback will be resource_uri,
                        # which is something all AJAX /hierarchy/id/?format=json responses share.
                        # however, if file type is possible, list file type
                        if data.title?
                            globalVars.hierarchyTitle = data.title
                        else if methods.getFileExtension(data.file_path)?
                            globalVars.hierarchyTitle = ".#{ methods.getFileExtension(data.file_path).toUpperCase() } File"
                        else
                            globalVars.hierarchyTitle = data.resource_uri
                        # globalVars.hierarchyTitle = if data.title then data.title else data.resource_uri
                        stackLink = $("<a />").html(globalVars.hierarchyTitle).attr
                            "data-id": globalVars.stackOpts.id
                            "data-hierarchy": globalVars.stackOpts.hierarchy
                            "href": ""
                            "class": "expand_flyout"
                        makeStackLI = "stack_#{ globalVars.stackOpts.hierarchy }"
                        stackLI = "##{ makeStackLI }"
                        stackMenu.prepend $("<li />").attr("id",makeStackLI).html stackLink
                        methods.makeMetaData $(stackLI),globalVars.stackOpts,data
                stackParent = methods.getParent globalVars.stackOpts.hierarchy
                # logic here: if the current hierarchy has a parent, continue the loop.
                if stackParent
                    parentID = methods.getParentID globalVars.stackOpts
                    globalVars.stackOpts.id = parentID
                # else, we are at journal level.
                else
                    stackLink = $("<a />").html("eJournals | Stacks").attr
                        "href": "/stacks/ejournal/"
                    stackMenu.prepend $("<li />").html stackLink
                globalVars.stackOpts.hierarchy = methods.getParent globalVars.stackOpts.hierarchy


        makeFileView: ( _this,options,data ) ->
            # remove the older make File View
            fileQuickView = "##{ settings.fileQuickViewID }"
            $(fileQuickView).remove()

            getFilelistSort = (a,b) ->
                # create an object where each fileType is given a value
                # first in fileList = 0, last in fileList = fileList.length - 1, etc.
                sortArray = {}
                for i,k in settings.fileListing
                    sortArray[settings.fileListing[k]] = k

                return -1 if sortArray[a[0]] < sortArray[b[0]]
                return 1 if sortArray[a[0]] > sortArray[b[0]]
                return 0

            # use testArray to attempt sorting
            # testArray = [
            #     ["html","1-html.html"]
            #     ["xml","2-xml.xml"]
            #     ["pdf","1-pdf.pdf"]
            #     ["xml","1-xml.xml"]
            #     ["html","2-html.html"]
            #     ["pdf","2-pdf.pdf"]
            # ]
            # testArray = testArray.sort(getFilelistSort)
            # console.log testArray

            fileList = []
            fileListIndex = 0
            for i in data
                stacksPath = i.stacks_get_transform_url
                fileExtension = methods.getFileExtension stacksPath
                # That is, if the file is not a file, then do not run.
                if fileExtension?
                    fileType = fileExtension
                    id = i.id
                    title = i.file_path

                    for i in settings.fileListing
                        if i is fileExtension
                            fileList[fileListIndex] = [
                                id
                                stacksPath
                                fileExtension
                                fileType
                                title
                            ]
                            fileListIndex++

            # sort list of files that match settings.fileListing by the order specified by it
            if fileList.length > 0
                fileList = fileList.sort(getFilelistSort)
                # format the list of files array, add the formatting linking
                for i,k in fileList
                    # that is, in the array:
                    # 0: id
                    # 1: path to render file
                    # 2: formatted extension, e.g., ".XML"
                    fileList[k][2] = ".#{ i[2].toUpperCase() }"
                    # 3: file type, e.g., "xml"
                    # 4: title of file, which will likely be its own file path
                    # 5: an anchor, e.g., $("<a />"), to append into DOM
                    fileList[k][5] = $("<a />").html(fileList[k][2]).attr
                        "data-hierarchy": methods.getChild options.hierarchy
                        "data-id": fileList[k][0]
                        "href": fileList[k][1]
                        "data-file-type": fileList[k][3]
                        "title": fileList[k][4]
                        "class": "view_file view_more_info"
                # create a footer between the header and the listing that gives the shortcut views
                _this.before $("<footer />").attr "id",settings.fileQuickViewID
                $(fileQuickView).html $("<em />").html "#{ settings.fileListText }: "
                for i,k in fileList
                    $(fileQuickView).append fileList[k][5]
                    if k < fileList.length - 1
                        $(fileQuickView).append " | "


        # method to prepare and create a canonical page.
        # For now, it only clears original content in preparation for adding new content.
        # *** REVISIT LATER *** this method will be used to do pushstates and permalinks.
        makeCanonical: ( _this, options ) ->
            fileQuickView = "##{ settings.fileQuickViewID }"
            $(fileQuickView).remove()
            # traverse commenting may have previously existed, remove as needed
            $(settings.traverse).remove()
            # orphan commenting may have previously existed, remove as needed
            $(globalVars.orphanComment).remove()
            # the page is reloading, check to make sure expand all is reset
            do methods.checkExpandAll


        makeTitleList: ( _this,options,data,descendant ) ->
            # child = methods.getChild options.hierarchy
            # a descendant is not stated if the title list is a listing for children of the original hierarchy.
            # if there is irregular traversing, e.g., orphans, the skipped descendant will be treated as the child.
            descendant = descendant or null
            if descendant?
                # irregular traversing
                child = descendant
            else
                # direct child of the original hierarchy
                child = methods.getChild options.hierarchy
            grandChild = methods.getChild child or null
            # create a title for the listing
            totalCount = data.length
            # inconsistent api means we do this for now
            # totalCount = if data.meta.total_count? then data.meta.total_count else data.length
            title = "This #{ options.hierarchy } has "
            title += "<strong class=\"#{ settings.listCountClass }\">#{ totalCount }</strong> #{ child }"
            if totalCount != 1 then title = "#{ title }s"
            _this.find("h2").find("strong").html title
            # if you can't expand further, then remove "expand all" link
            if !methods.getChild(child) or totalCount is 0
                _this.find("h2").find("span").hide()
            else
                _this.find("h2").find("span").show()

            # remove old listing
            _this.find("h2").siblings("ul").remove()
            _this.find("h2").siblings("p").remove()

            # create a new <UL> for the listing, only if the listing is for children and not descendants
            if descendant == null
                makeUL = "list_#{ options.hierarchy }_#{ options.id }"
                ulClass = ".#{ makeUL }"
                # _this.append $("<ul />").addClass(makeUL).addClass "list_#{ options.hierarchy }"
                _this.append $("<ul />").attr
                    "data-hierarchy": options.hierarchy
                    "data-id": options.id
                    "class": "#{ makeUL } list_#{ options.hierarchy } list_title"
                    "id": settings.listingID
                # $(ulClass).addClass "list_title"
            # basically, if child has no children, we've reached end of the line
            if !grandChild?
                # end of the line is always files, so do file shortcutting links, e.g., "quick view"
                methods.makeFileView $(ulClass),options,data
            ulClass


        makeExpandList: ( _this, options, childData ) ->
            child = methods.getChild options.hierarchy
            parentElement = _this.parent()
            makeUL = "list_#{ options.hierarchy }_#{ options.id }"
            ulClass = ".#{ makeUL }"
            parentElement.children("span").after $("<ul />").addClass(makeUL).addClass "list_#{ options.hierarchy }"
            # end of the line is always files, so do file shortcutting links, e.g., "quick view"
            if methods.getChild(child) == undefined
                methods.makeFileView _this.siblings("ul"),options,childData
            ulClass


        makeFlyout: (_this,options) ->
            flyoutDiv = "flyout_#{ options.hierarchy }_#{ options.id }"
            flyoutClass = ".#{ flyoutDiv }"
            # create the flyout div, give it classes and data attributes
            _this.parent().append $("<div />").addClass("#{ flyoutDiv } stack_flyout").attr
                "data-hierarchy": options.hierarchy
            # since truncating may have occured, ajax to find original title of stack menu link
            # TRUNCATING TO BE DONE LATER!
            # if _this.height() > settings.stackLineHeight * (settings.stackLineLimit - 1)
            #     $.ajax
            #         url: "/api/v1/stacks/#{ options.hierarchy }/#{ options.id }/"
            #         dataType: "json"
            #         data:
            #             format: "json"
            #         success: (data) ->
            #             globalVars.linkTitle = data.title
            #             # console.log globalVars.linkTitle
            # else
            #     globalVars.linkTitle = _this.html()
            # console.log globalVars
            # console.log globalVars[4]
            # first link in flyout div goes to the referencing stack menu item
            # For example, the stack menu item for a volume will create a div,
            # first link in Div will go to that volume. 
            # We are doing click + click instead of hover + click to anticipate tablets, finger gestures
            flyoutLink = $("<a />").html(_this.html()).attr
                "data-id": options.id
                "data-hierarchy": options.hierarchy
                "class": "expand_list"
                "href": ""
            $(flyoutClass).append $("<p />").html(flyoutLink)
            makeUL = "list_#{ options.hierarchy }_#{ options.id }"
            ulClass = ".#{ makeUL }"
            $(flyoutClass).append $("<ul />").addClass makeUL
            ulClass


        # there is a listener whenever a flyout is triggered, see flyoutDancer.js.
        # the listener will look for an offset value and the creation of span.flyout_complete
        makeFlyoutListener: (_this,offset) ->
            _this.css "top",settings.flyoutTopPos
            _this.attr "data-offset", offset
            flyoutCompleteClass = ".#{ settings.flyoutComplete }"
            _this.find(flyoutCompleteClass).remove()
            _this.append $("<span />").addClass settings.flyoutComplete


# This AJAX method will accept an object that has id and hierarchy level and will generate all children.
# The JSON response will give an data array that represents object's children.
# E.g. if the object hierarchy is a volume and its ID is 1234,
# the API call will be /api/v1/stacks/volume-expanded/1234/?format=json and in the JSON data,
# there will be an object named data.issues, which will will list children of volume 1234.
# Essentially, user will be able see a page displaying info for a journal, volume, issue, or article
# such that a canonical URL is available.
        canonicalAjax: (_this,options) ->
            # if children are not possible (e.g. files)
            # that is, if at this level, children are possible, then show children
            if methods.getChild(options.hierarchy)?
                $.ajax
                    url: "/api/v1/stacks/#{ options.hierarchy }-expanded/#{ options.id }/"
                    dataType: "json"
                    data:
                        format: "json"
                    beforeSend: (jqXHR, settings) ->
                        # methods.ajaxLoad generates a loading animation
                        # remember that it is not an on/off switch, but a button,
                        # press it and it will go to the opposite state of what it is.
                        do methods.makeAjaxLoad
                        jqXHR.setRequestHeader('X-CSRFToken', $('input[name=csrfmiddlewaretoken]').val())
                    success: (data) ->
                        # build the stacks menu
                        methods.makeStacks options
                        # clear out the page to set up for a canonical page and listing
                        methods.makeCanonical _this,options

                        # The Stacks hierarchy-expanded JSON response does not list files as children,
                        # as an article-expanded response would list both data.files and data.all_files
                        # ( all levels of hierarchy list data.all_files), thereby creating redundancy.
                        # Therefore, if grandchildren is not possible, childData IS all_files.
                        if methods.getChild(methods.getChild(options.hierarchy))?
                            # each expanded api will deliver an object named after its child,
                            # containing an array of children.
                            # E.g. data for volume-expanded will have data.issues, which is itself an array
                            childData = data["#{ methods.getChild options.hierarchy }s"]
                        else
                            # if an article is to render files
                            childData = data.all_files

                        # creates the <UL> and what is needed in preparation to populate with data.
                        ulClass = methods.makeTitleList _this,options,childData
                        
                        if childData != undefined
                            # Assuming object can have children, if any children exist
                            if childData.length > 0
                                if !methods.getChild(methods.getChild(options.hierarchy))?
                                    # create a new object from data.objects, where data.objects are sorted by file path
                                    childData = childData.sort methods.getFilePathSort
                                # this method works if and only if proper structure and hierarchy exist
                                for i in childData
                                    # Note that listExpandAjax, flyoutAjax, and makeMyOrphans
                                    # all use methods.makeDropdownLI as it loops through childData
                                    entry = methods.makeDropdownLI i, options
                                    # that is, an attempt to make a new list item from children did not return null
                                    if entry?
                                        $(ulClass).prepend entry 
                                    else
                                        # trim the list count by one
                                        methods.getListCut $(ulClass)

                        # methods.makeTitleList creates both a canonical page and initiates the child listing
                        # if child listing cannot be generated, get rid of that list container.
                        if childData is undefined or childData.length is 0
                            $(ulClass).remove()

                        # Build the Orphan Listing by looping through all possible orphan types
                        methods.makeOrphanLoop _this, options, data

                        # hit the loading animation again after all data has been populated onto page
                        do methods.makeAjaxLoad


# this methods for AJAX calls will take expand all children, based on hierarchy. For example, if the user
# clicks on volume link, the listing will expand to show all issues of that volume. The URL state does not change
# based on these calls.
        listExpandAjax: ( _this,options ) ->
            # That is, if a child listing hasn't already been created.
            # Explanation: see stacks.css for .expand_list ~ ul { display: none; }
            # Clicking on the name of the item in the dropdown list acts as a toggle.
            # first time clicking will make the call for this method.
            # second time clicking will hide it.
            # third time click does not make the call because _this.parent().children("ul").length === 1
            # instead, only show the child list again.
            if _this.parent().children("ul").length is 0
                $.ajax
                    url: "/api/v1/stacks/#{ options.hierarchy }-expanded/#{ options.id }/"
                    dataType: "json"
                    data:
                        format: "json"
                    beforeSend: () ->
                        do methods.makeAjaxLoad
                    success : (data) ->
                        # The Stacks hierarchy-expanded JSON response does not list files as children,
                        # as an article-expanded response would list both data.files and data.all_files
                        # ( all levels of hierarchy list data.all_files), thereby creating redundancy.
                        # Therefore, if grandchildren is not possible, childData IS all_files.
                        if methods.getChild(methods.getChild(options.hierarchy))?
                            # each expanded api will deliver an object named after its child,
                            # containing an array of children.
                            # E.g. data for volume-expanded will have data.issues, which is itself an array
                            childData = data["#{ methods.getChild options.hierarchy }s"]
                        else
                            # if an article is to render files
                            childData = data.all_files

                        # if at this level of hierarchy, the object can have child objects
                        if childData != undefined
                            # Assuming object can have children, if any children exist
                            if childData.length > 0
                                if !methods.getChild(methods.getChild(options.hierarchy))?
                                    # create a new object from data.objects, where data.objects are sorted by file path
                                    childData = childData.sort methods.getFilePathSort
                                # this method works if and only if proper structure and hierarchy exist
                                ulClass = methods.makeExpandList _this, options, childData
                                for i in childData
                                    # Note that canonicalAjax, flyoutAjax, and makeMyOrphans
                                    # all use methods.makeDropdownLI as it loops through childData
                                    entry = methods.makeDropdownLI i, options
                                    # that is, an attempt to make a new list item from children did not return null
                                    if entry?
                                        $(ulClass).prepend entry 
                                    else
                                        # trim the list count by one
                                        methods.getListCut $(ulClass)

                        # Build the Orphan Listing by looping through all possible orphan types
                        methods.makeOrphanLoop _this.parent(), options, data

                        # hit the loading animation again after all data has been populated onto page
                        do methods.makeAjaxLoad



        
# These methods for AJAX calls make the flyout menus from the stack menu.
# flyout positioning is based on an DOM listener looking for span.flyout_complete.
# since it has already been created the first time the div was generated, trigger
# the listener again by removing and creating it again.
        flyoutAjax: (_this,options) ->
            # Flyout is absolutely positioned, so it needs an offset to position itself
            offset = _this.offset().top - settings.flyoutTopPad
            # That is, if a flyout hasn't already been created.
            # Explanation: see nav.css for #stack_menu > li .stack_flyout {  display: none; }
            # vs. #stack_menu > li.selected .stack_flyout { display: block; }
            # Clicking on the stack menu link acts a toggle
            # first time clicking will make the call for this method.
            # second time clicking will hide it.
            # third time click does not make the call because _this.siblings("div").length === 1
            # instead, resurface the flyout by giving a .select class to stack menu. See methods.init
            if _this.siblings("div").length is 0
                $.ajax
                    url: "/api/v1/stacks/#{ options.hierarchy }-expanded/#{ options.id }/"
                    dataType: "json"
                    async: false
                    data:
                        format: "json"
                    beforeSend: () ->
                        do methods.makeAjaxLoad
                    success : (data) ->
                        # each expanded api will deliver an object named after its child,
                        # containing an array of children.
                        # E.g. data for volume-expanded will have data.issues, which is itself an array
                        childData = data["#{ methods.getChild options.hierarchy }s"]
                        # Defaults to data.all_files if children array cannot be found
                        if childData is undefined
                            childData = data.all_files
                        ulClass = methods.makeFlyout _this,options
                        for i in childData
                            # Note that methods.canonicalAjax and methods.listExpandAjax also 
                            # as both use methods.makeDropdownLI as it loops through childData
                            entry = methods.makeDropdownLI i, options
                            $(settings.stackMenu).find(ulClass).prepend entry
                        do methods.makeAjaxLoad
                    complete: ->
                        # the listener will create an element for which the mutation observers in
                        # flyout_dancer.js is watching.
                        methods.makeFlyoutListener _this.siblings("div"),offset
            else
                # triggers flyout_dancer.js, which is the plugin to resize flyout menus to fit the page.
                # the trigger is done again after page scrolling. That is, the following occurs when
                # 1. the user has already created flyout and 2. at some point, the user scrolled on the page.
                if _this.siblings("div").attr("data-offset") > 0
                    methods.makeFlyoutListener _this.siblings("div"),offset


    $.fn.ajaxCalls = ( method ) ->
        if methods[method]
            methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ) )
        else if typeof method is 'object' or not method
            methods.init.apply this, arguments
        else
            $.error "Method #{ method } does not exist on jQuery.ajaxCalls"



        # # Preserving the older version of expand ajax as a reference.
        # # See the explanation for methods.volumeAjax() for reasoning for retiring methods.volumeExpandAjax()
        # volumeExpandAjax: (_this,options) ->
        #     if _this.parent().children("ul").length is 0
        #         $.ajax
        #             url: "/api/v1/stacks/#{ methods.getChild options.hierarchy  }/"
        #             dataType: "json"
        #             data:
        #                 format: "json"
        #                 volume: options.id
        #             beforeSend: () ->
        #                 do methods.makeAjaxLoad
        #             success : (data) ->
        #                 ulClass = methods.makeExpandList _this, options
        #                 if data.objects.length is 0
        #                     methods.volumeTraversalAjax $(ulClass),options
        #                 else
        #                     for i in data.objects
        #                         entry = methods.makeDropdownLI i, options
        #                         $(ulClass).prepend entry 
        #                     do methods.makeAjaxLoad


        # # we are going to keep the older version of stacks call as a reference
        # # This API request is slower, as it is actually doing,
        # # given an object with id and hierarchy, find all objects that are one level of hierarchy down,
        # # filtered by the id of the given id.
        # # these 4 methods for AJAX calls (journalAjax, volumeAjax, issueAjax, and articleAjax)
        # # will generate what will appear visuaually as new pages.
        # # Essentially, user will be able see a page displaying info for a journal, volume, issue,
        # # or article such that a canonical URL is available.
        # articleAjax: (_this,options) ->
        #     $.ajax
        #         url: "/api/v1/stacks/#{ methods.getChild options.hierarchy  }/"
        #         dataType: "json"
        #         data:
        #             # note exception says article(s)
        #             articles: options.id
        #             format: "json"
        #         beforeSend: () ->
        #             do methods.makeAjaxLoad
        #         success: (data) ->
        #             methods.makeStacks options
        #             ulClass = methods.makeTitleList _this,options,data
        #             dataObjects = data.objects.sort methods.getFilePathSort
        #             for i in dataObjects
        #                 entry = methods.makeDropdownLI i, options
        #                 _this.find(ulClass).append entry
        #             methods.makeFileView _this,data.objects,methods.getChild options.hierarchy
        #             do methods.makeAjaxLoad



        # # Preserving the older version of expand ajax as a reference.
        # # See the explanation for methods.volumeAjax() for reasoning for retiring methods.volumeFlyoutAjax()
        # volumeFlyoutAjax: (_this,options) ->
        #     offset = _this.offset().top - settings.flyoutTopPad
        #     if _this.siblings("div").length is 0
        #         $.ajax
        #             url: "/api/v1/stacks/#{ methods.getChild options.hierarchy  }/"
        #             dataType: "json"
        #             async: false
        #             data:
        #                 format: "json"
        #                 volume: options.id
        #             success : (data) ->
        #                 ulClass = methods.makeFlyout _this,options
        #                 globalVars.ulClass = ulClass
        #                 for i in data.objects
        #                     entry = methods.makeDropdownLI i, options
        #                     $(settings.stackMenu).find(ulClass).prepend entry
        #             complete: ->
        #                 methods.makeFlyoutListener _this.siblings("div"),offset
        #     else
        #         if _this.siblings("div").attr("data-offset") > 0
        #             methods.makeFlyoutListener _this.siblings("div"),offset


        # # Preserving the older version of ajax traversal as a reference.
        # # if a level can't find any children, it will find grandchildren, and comment accordingly.
        # # e.g. if an issue has no articles, a text comment will appear to say, 
        # # "This issue has no articles, but contains #### files."
        # # DOL = data.objects.length
        # # if there is no length, the impliction is that there are no further entries, e.g. an article with no files.
        # makeTraverseComment: (options, DOL) ->
        #     DOL = DOL or null
        #     if DOL?
        #         child = methods.getChild options.hierarchy
        #         grandChild = methods.getChild child
        #         textString = "This #{ options.hierarchy } has no #{ child }s, but contains "
        #         textString = "#{ textString } <strong>#{ DOL }</strong> #{ grandChild }"
        #         if DOL != 1
        #             textString = "#{ textString }s"
        #         textString = "#{ textString }."
        #     else
        #         textString = "This #{ options.hierarchy } contains no further entries."
        #     traverseComment = $("<p />").html(textString).addClass settings.traverseClass


        # # Preserving the older version of ajax traversal as a reference.
        # # These methods will traverse hierachy, or skip one level. These methods WILL NOT skip 2 levels
        # # Ajax call that is made when volume has no issues.
        # volumeTraversalAjax: (_this,options) ->
        #     child = methods.getChild options.hierarchy
        #     grandChild = methods.getChild child or null
        #     traverseOpts = 
        #         id: options.id
        #         hierarchy: child
        #     if grandChild?
        #         $.ajax
        #             url: "/api/v1/stacks/#{ grandChild }/"
        #             dataType: "json"
        #             data: 
        #                 volumes: options.id
        #                 format: "json"
        #             success: (data) ->
        #                 traverseComment = methods.makeTraverseComment options,data.objects.length
        #                 _this.before traverseComment
        #                 # create a new object from data.objects, where data.objects are sorted by file path
        #                 dataObjects = data.objects.sort methods.getFilePathSort
        #                 for i, j in dataObjects
        #                     entry = methods.makeDropdownLI i, traverseOpts
        #                     _this.prepend entry
        #             complete: () ->
        #                 do methods.makeAjaxLoad
        #     else
        #         traverseComment = methods.makeTraverseComment options
        #         _this.before traverseComment


