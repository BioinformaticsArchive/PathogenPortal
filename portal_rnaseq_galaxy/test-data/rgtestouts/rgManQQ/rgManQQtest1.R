
# generalised so 3 core fields passed as parameters ross lazarus March 24 2010 for rgenetics
# Originally created as qqman with the following 
# attribution:
#--------------
# Stephen Turner
# http://StephenTurner.us/
# http://GettingGeneticsDone.blogspot.com/

# Last updated: 19 July 2011 by Ross Lazarus
# R code for making manhattan plots and QQ plots from plink output files. 
# With GWAS data this can take a lot of memory. Recommended for use on 
# 64bit machines only, for now. 

#

library(ggplot2)

coloursTouse = c('firebrick','darkblue','goldenrod','darkgreen')
# not too ugly but need a colour expert please...


DrawManhattan = function(pvals=Null,chrom=Null,offset=Null,title=NULL, max.y="max",suggestiveline=0, genomewide=T, size.x.labels=9, 
              size.y.labels=10, annotate=F, SNPlist=NULL,grey=0) {
        if (annotate & is.null(SNPlist)) stop("You requested annotation but provided no SNPlist!")
        genomewideline=NULL # was genomewideline=-log10(5e-8)
        n = length(pvals)
        if (genomewide) { # use bonferroni since might be only a small region?
            genomewideline = -log10(0.05/n) }
        offset = as.integer(offset)
        if (n > 1000000) { offset = offset/10000 }
        else if (n > 10000) { offset = offset/1000}
        chro = as.integer(chrom) # already dealt with X and friends?
        pvals = as.double(pvals)
        d=data.frame(CHR=chro,BP=offset,P=pvals)
        if ("CHR" %in% names(d) & "BP" %in% names(d) & "P" %in% names(d) ) {
                d=d[!is.na(d$P), ]
                d=d[!is.na(d$BP), ]
                d=d[!is.na(d$CHR), ]
                #limit to only chrs 1-22, x=23,y=24,Mt=25?
                d=d[d$CHR %in% 1:25, ]
                d=d[d$P>0 & d$P<=1, ]
                d$logp = as.double(-log10(d$P))
                dlen = length(d$P)
                d$pos=NA
                ticks=NULL
                lastbase=0
                chrlist = unique(d$CHR)
                chrlist = as.integer(chrlist)
                chrlist = sort(chrlist) # returns lexical ordering 
                if (max.y=="max") { maxy = ceiling(max(d$logp)) } 
                   else { maxy = max.y }
                nchr = length(chrlist) # may be any number?
                maxy = max(maxy,1.1*genomewideline)
                if (nchr >= 2) {
                    for (x in c(1:nchr)) {
                        i = chrlist[x] # need the chrom number - may not == index
                        if (x == 1) { # first time
                            d[d$CHR==i, ]$pos = d[d$CHR==i, ]$BP # initialize to first BP of chr1
                            dsub = subset(d,CHR==i)
                            dlen = length(dsub$P)
                            lastbase = max(dsub$pos) # last one
                            tks = d[d$CHR==i, ]$pos[floor(length(d[d$CHR==i, ]$pos)/2)+1]
                            lastchr = i
                        } else {
                            d[d$CHR==i, ]$pos = d[d$CHR==i, ]$BP+lastbase # one humongous contig
                            if (sum(is.na(lastchr),is.na(lastbase),is.na(d[d$CHR==i, ]$pos))) { 
                                cat(paste('manhattan: For',title,'chrlistx=',i,'lastchr=',lastchr,'lastbase=',lastbase,'pos=',d[d$CHR==i,]$pos))
                             }   
                            tks=c(tks, d[d$CHR==i, ]$pos[floor(length(d[d$CHR==i, ]$pos)/2)+1])
                            lastchr = i
                            dsub = subset(d,CHR==i)
                            lastbase = max(dsub$pos) # last one
                        }
                    ticklim=c(min(d$pos),max(d$pos))
                    xlabs = chrlist
                    }
                } else { # nchr is 1
                   nticks = 10
                   last = max(d$BP)
                   first = min(d$BP)
                   tks = c(first)
                   t = (last-first)/nticks # units per tick
                   for (x in c(1:(nticks))) { 
                        tks = c(tks,round(x*t)+first) }
                   ticklim = c(first,last)
                } # else
                if (grey) {mycols=rep(c("gray10","gray60"),max(d$CHR))
                           } else {
                           mycols=rep(coloursTouse,max(d$CHR))
                           }
                dlen = length(d$P)
                d$pranks = rank(d$P)/dlen
                d$centiles = 100*d$pranks # small are interesting
                d$sizes = ifelse((d$centile < 1),2,1)
                if (annotate) d.annotate=d[as.numeric(substr(d$SNP,3,100)) %in% SNPlist, ]
                if (nchr >= 2) {
                        manplot=qplot(pos,logp,data=d, ylab=expression(-log[10](italic(p))) , colour=factor(CHR),size=factor(sizes))
                        manplot=manplot+scale_x_continuous(name="Chromosome", breaks=tks, labels=xlabs,limits=ticklim) 
                        manplot=manplot+scale_size_manual(values = c(0.5,1.5)) # requires discreet scale - eg factor
                        #manplot=manplot+scale_size(values=c(0.5,2)) # requires continuous 
                        }
                else {
                        manplot=qplot(BP,logp,data=d, ylab=expression(-log[10](italic(p))) , colour=factor(CHR))
                        manplot=manplot+scale_x_continuous(name=paste("Chromosome",chrlist[1]), breaks=tks, labels=tks,limits=ticklim) 
                     }                 
                manplot=manplot+scale_y_continuous(limits=c(0,maxy), breaks=1:maxy, labels=1:maxy)
                manplot=manplot+scale_colour_manual(value=mycols)
                if (annotate) {  manplot=manplot + geom_point(data=d.annotate, colour=I("green3")) } 
                manplot=manplot + opts(legend.position = "none") 
                manplot=manplot + opts(title=title)
                manplot=manplot+opts(
                     panel.background=theme_blank(), 
                     axis.text.x=theme_text(size=size.x.labels, colour="grey50"), 
                     axis.text.y=theme_text(size=size.y.labels, colour="grey50"), 
                     axis.ticks=theme_segment(colour=NA)
                )
                if (suggestiveline) manplot=manplot+geom_hline(yintercept=suggestiveline,colour="blue", alpha=I(1/3))
                if (genomewideline) manplot=manplot+geom_hline(yintercept=genomewideline,colour="red")
                manplot
        }       else {
                stop("Make sure your data frame contains columns CHR, BP, and P")
        }
}



qq = function(pvector, title=NULL, spartan=F) {
        # Thanks to Daniel Shriner at NHGRI for providing this code for creating expected and observed values
        o = -log10(sort(pvector,decreasing=F))
        e = -log10( 1:length(o)/length(o) )
        # you could use base graphics
        # plot(e,o,pch=19,cex=0.25, xlab=expression(Expected~~-log[10](italic(p))), 
        # ylab=expression(Observed~~-log[10](italic(p))), xlim=c(0,max(e)), ylim=c(0,max(e)))
        # lines(e,e,col="red")
        #You'll need ggplot2 installed to do the rest
        qq=qplot(e,o, xlim=c(0,max(e)), ylim=c(0,max(o))) + stat_abline(intercept=0,slope=1, col="red")
        qq=qq+opts(title=title)
        qq=qq+scale_x_continuous(name=expression(Expected~~-log[10](italic(p))))
        qq=qq+scale_y_continuous(name=expression(Observed~~-log[10](italic(p))))
        if (spartan) plot=plot+opts(panel.background=theme_rect(col="grey50"), panel.grid.minor=theme_blank())
        qq
}

rgqqMan = function(infile="/data/tmp/tmpNaxDwH/database/files/000/dataset_1.dat",chromcolumn=2, offsetcolumn=3, pvalscolumns=c(8), 
title="rgManQQtest1",grey=0) {
rawd = read.table(infile,head=T,sep='\t')
dn = names(rawd)
cc = dn[chromcolumn]
oc = dn[offsetcolumn] 
rawd[,cc] = sub('chr','',rawd[,cc],ignore.case = T) # just in case
rawd[,cc] = sub(':','',rawd[,cc],ignore.case = T) # ugh
rawd[,cc] = sub('X',23,rawd[,cc],ignore.case = T)
rawd[,cc] = sub('Y',24,rawd[,cc],ignore.case = T)
rawd[,cc] = sub('Mt',25,rawd[,cc], ignore.case = T)
nams = c(cc,oc) # for sorting
plen = length(rawd[,1])
print(paste('###',plen,'values read from',infile,'read - now running plots',sep=' '))
rawd = rawd[do.call(order,rawd[nams]),]
# mmmf - suggested by http://onertipaday.blogspot.com/2007/08/sortingordering-dataframe-according.html
# in case not yet ordered
if (plen > 0) {
  for (pvalscolumn in pvalscolumns) {
  if (pvalscolumn > 0) 
     {
     cname = names(rawd)[pvalscolumn]
     mytitle = paste('p=',cname,', ',title,sep='')
     myfname = chartr(' ','_',cname)
     myqqplot = qq(rawd[,pvalscolumn],title=mytitle)
     ggsave(filename=paste(myfname,"qqplot.png",sep='_'),myqqplot,width=8,height=6,dpi=96)
     ggsave(filename=paste(myfname,"qqplot.pdf",sep='_'),myqqplot,width=8,height=6,dpi=96)
     print(paste('## qqplot on',cname,'done'))
     if ((chromcolumn > 0) & (offsetcolumn > 0)) {
         print(paste('## manhattan on',cname,'starting',chromcolumn,offsetcolumn,pvalscolumn))
         mymanplot= DrawManhattan(chrom=rawd[,chromcolumn],offset=rawd[,offsetcolumn],pvals=rawd[,pvalscolumn],title=mytitle,grey=grey)
         ggsave(filename=paste(myfname,"manhattan.png",sep='_'),mymanplot,width=8,height=6,dpi=96)
         ggsave(filename=paste(myfname,"manhattan.pdf",sep='_'),mymanplot,width=8,height=6,dpi=96)
         print(paste('## manhattan plot on',cname,'done'))
         }
         else {
              print(paste('chrom column =',chromcolumn,'offset column = ',offsetcolumn,
              'so no Manhattan plot - supply both chromosome and offset as numerics for Manhattan plots if required'))
              } 
     } 
  else {
        print(paste('pvalue column =',pvalscolumn,'Cannot parse it so no plots possible'))
      }
  } # for pvalscolumn
 } else { print('## Problem - no values available to plot - was there really a chromosome and offset column?') }
}

rgqqMan() 
# execute with defaults as substituted

#R script autogenerated by rgenetics/rgutils.py on 04/08/2011 11:46:16
