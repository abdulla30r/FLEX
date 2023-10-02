%{
    #include <string.h>

    int isBegin = 0;
    int error = 0;
    int isEnd = 0;
    int stmt =0;
    int loop =0;
    int ifCount =0;
    int multiComment=0;
    int inMulti =0;
    struct symbolTable{
        char type[10];
        char name[256];
    };

    struct symbolTable table[200];

    void trimNewline(char *str) {
        int length = strlen(str);
        
        while (length > 0 && (str[length - 1] == '\n' || str[length - 1] == '\r')) {
            str[length - 1] = '\0';
            length--;
        }
    }
%}

spnl ([ ]|[\n])*
digit [0-9]
vName [a-zA-Z]+[a-zA-Z0-9]*
start (SHURU)
end (SHESH)
input (NAO)[ ]+{vName}{spnl}
output (DAO)[ ]+{vName}{spnl}
integer (PURNO)[ ]+{vName}[ ]*(([,][ ]*{vName})*[ ]*|[ ]*[=]{digit}+)*
float (VOGNO)[ ]+{vName}[ ]*(([,][ ]*{vName})*[ ]*|[ ]*[=]{digit}*[.]?{digit}+)*
relop [>]|[<]|[=]|(>=)|(<=)|(!)
arop [+]|[-]|[*]|[/]
stmt {input}|{output}|({vName}[ ]*[=][ ]*({vName}|{digit}+))
loop (LOOP)[\n]{con}[\n]{loopInc}[\n]([ ]*{stmt}[\n])*(POOL)
con (SHORTO)[ ]+({vName}|{digit}+)[ ]*{relop}[ ]*({vName}|{digit}+)
loopInc (INC)[ ]*{vName}[ ]*{arop}[=][ ]*({vName}|{digit}+)
if (JODI)[\n]{con}[\n](HOY)[\n]([ ]*{stmt}[\n])+{spnl}((NAHOY)[\n]([ ]*{stmt}[\n])+{spnl})?(IDOJ)

singleComment [#][^\n]*


%%
{singleComment} 
(<--) {
    inMulti = 1;
}

(-->) {
    inMulti = 0;
}

{start} {
    if(error!=0 || isBegin!=0 ){
        return 0;
    }
    else{
        ++isBegin;
    }
}

{stmt} {
    if (error != 0 || isBegin != 1 || isEnd != 0) {
        error++;
        return 0;
    } else {
        stmt++;
    }
}

{integer}|{float} {
    if (error != 0 || isBegin != 1 || isEnd != 0) {
        error++;
        return 0;
    } else {
        stmt++;
    }
}

{loop} {
    if (error != 0 || isBegin != 1 || isEnd != 0) {
        error++;
        return 0;
    } 
    else{
        loop++;
    }
}

{if} {
    if (error != 0 || isBegin != 1 || isEnd != 0) {
        error++;
        return 0;
    } 
    else{
        ifCount++;
    }
}



{end} {
    if(error!=0 || isBegin==0){
        error++;
    }
    else{
        isBegin=0;
        ++isEnd;
    }
}



. {
    if (!inMulti) {
        error++;
        trimNewline(yytext);
        printf("%s", yytext);
    }
}

[\n] {}
%%

int yywrap()
{
}

int main()
{
    yyin=fopen("input.txt","r");
    yylex(); 
    if(error==0){
        if(isEnd!=1 || isBegin==1){
            printf("BEGIN END Problem\n");
        }
        else{
            printf("Total Statement: %d\n",stmt);
            printf("Total Loop: %d\n",loop);
            printf("Total IfElse: %d\n",ifCount);
            printf("Your source code is OK :)\n");
        }
    }
    else{
        printf("\nTry Again :'( \n");
    }
}
