(function(){var b=Handlebars.template,a=Handlebars.templates=Handlebars.templates||{};a["template-visualization-dataControl"]=b(function(g,n,f,m,l){f=f||g.helpers;var j="",d,i,h="function",k=this.escapeExpression,q=this;function e(v,u){var s="",t,r;s+='\n            <option value="';r=f.index;if(r){t=r.call(v,{hash:{}})}else{t=v.index;t=typeof t===h?t():t}s+=k(t)+'">';r=f.name;if(r){t=r.call(v,{hash:{}})}else{t=v.name;t=typeof t===h?t():t}s+=k(t)+"</option>\n        ";return s}function c(v,u){var s="",t,r;s+='\n            <option value="';r=f.index;if(r){t=r.call(v,{hash:{}})}else{t=v.index;t=typeof t===h?t():t}s+=k(t)+'">';r=f.name;if(r){t=r.call(v,{hash:{}})}else{t=v.name;t=typeof t===h?t():t}s+=k(t)+"</option>\n        ";return s}function p(v,u){var s="",t,r;s+='\n            <option value="';r=f.index;if(r){t=r.call(v,{hash:{}})}else{t=v.index;t=typeof t===h?t():t}s+=k(t)+'">';r=f.name;if(r){t=r.call(v,{hash:{}})}else{t=v.name;t=typeof t===h?t():t}s+=k(t)+"</option>\n        ";return s}function o(s,r){return'checked="true"'}j+="<p class=\"help-text\">\n        Use the following controls to change the data used by the chart.\n        Use the 'Draw' button to render (or re-render) the chart with the current settings.\n    </p>\n\n    ";j+='\n    <div class="column-select">\n        <label for="X-select">Data column for X: </label>\n        <select name="X" id="X-select">\n        ';d=n.numericColumns;d=f.each.call(n,d,{hash:{},inverse:q.noop,fn:q.program(1,e,l)});if(d||d===0){j+=d}j+='\n        </select>\n    </div>\n    <div class="column-select">\n        <label for="Y-select">Data column for Y: </label>\n        <select name="Y" id="Y-select">\n        ';d=n.numericColumns;d=f.each.call(n,d,{hash:{},inverse:q.noop,fn:q.program(3,c,l)});if(d||d===0){j+=d}j+="\n        </select>\n    </div>\n\n    ";j+='\n    <div id="include-id">\n        <label for="include-id-checkbox">Include a third column as data point IDs?</label>\n        <input type="checkbox" name="include-id" id="include-id-checkbox" />\n        <p class="help-text-small">\n            These will be displayed (along with the x and y values) when you hover over\n            a data point.\n        </p>\n    </div>\n    <div class="column-select" style="display: none">\n        <label for="ID-select">Data column for IDs: </label>\n        <select name="ID" id="ID-select">\n        ';d=n.allColumns;d=f.each.call(n,d,{hash:{},inverse:q.noop,fn:q.program(5,p,l)});if(d||d===0){j+=d}j+="\n        </select>\n    </div>\n\n    ";j+='\n    <div id="first-line-header" style="display: none;">\n        <p>Possible headers: ';i=f.possibleHeaders;if(i){d=i.call(n,{hash:{}})}else{d=n.possibleHeaders;d=typeof d===h?d():d}j+=k(d)+'\n        </p>\n        <label for="first-line-header-checkbox">Use the above as column headers?</label>\n        <input type="checkbox" name="include-id" id="first-line-header-checkbox"\n            ';d=n.usePossibleHeaders;d=f["if"].call(n,d,{hash:{},inverse:q.noop,fn:q.program(7,o,l)});if(d||d===0){j+=d}j+='/>\n        <p class="help-text-small">\n            It looks like Galaxy couldn\'t get proper column headers for this data.\n            Would you like to use the column headers above as column names to select columns?\n        </p>\n    </div>\n\n    <input id="render-button" type="button" value="Draw" />\n    <div class="clear"></div>';return j})})();