
    var i = -1;
    var listeCoche=[".",".",".",".",".",".",".",".","."];

    function addImage(image){
        let joueurActuel = document.getElementById("joueur");
        let casesRemplies = document.getElementsByClassName("remplie");


        if(image.classList.contains('rouge') || image.classList.contains('bleu')){
            console.log("Veuillez choisir une case vide.");
            
        }
        else{
            if(i >= 7){
                if (i%2 == 0){
                    image.src = "img/rouge.png";
                    image.classList.add("rouge");
                    listeCoche[image.alt-1] = "Rouge";
                    console.log(listeCoche);
                }
                else{
                    image.src = "img/bleu.png";
                    image.classList.add("bleu");
                    listeCoche[image.alt-1] = "Bleu";
                    console.log(listeCoche);
                }
                newGame(gagnant = "NUL");
            }

            else if(i%2 == 0){
                joueurActuel.innerHTML = "Au tour du Joueur O";
                image.src = "img/rouge.png";
                image.classList.add("rouge");
                listeCoche[image.alt-1] = "Rouge";
                console.log(listeCoche);
                i+=1;
                checkVictoire();
            }
            else if (i%2 != 0){
                joueurActuel.innerHTML = "Au tour du Joueur X";
                image.src = "img/bleu.png";
                image.classList.add("bleu");
                listeCoche[image.alt-1] = "Bleu";
                console.log(listeCoche);
                i+=1;
                checkVictoire();
            }
        }
    }

    function checkVictoire(){
        // 123
        if(listeCoche[0]=="Rouge" && listeCoche[1]=="Rouge" && listeCoche[2]=="Rouge"){
            console.log("VICTOIRE JOUEUR X");
            coloriageCase(x=0,y=1,z=2);
            newGame(gagnant = "Joueur X");
        }

        else if (listeCoche[0]=="Bleu" && listeCoche[1]=="Bleu" && listeCoche[2]=="Bleu"){
            console.log("VICTOIRE JOUEUR O");
            coloriageCase(x=0,y=1,z=2);
            newGame(gagnant = "Joueur O");
        }

        // 456
        else if(listeCoche[3]=="Rouge" && listeCoche[4]=="Rouge" && listeCoche[5]=="Rouge"){
            console.log("VICTOIRE JOUEUR X");
            coloriageCase(x=3,y=4,z=5);
            newGame(gagnant = "Joueur X");
        }

        else if (listeCoche[3]=="Bleu" && listeCoche[4]=="Bleu" && listeCoche[5]=="Bleu"){
            console.log("VICTOIRE JOUEUR O");
            coloriageCase(x=3,y=4,z=5);
            newGame(gagnant = "Joueur O");
        }

        //789
        else if(listeCoche[6]=="Rouge" && listeCoche[7]=="Rouge" && listeCoche[8]=="Rouge"){
            console.log("VICTOIRE JOUEUR X");
            coloriageCase(x=6,y=7,z=8);
            newGame(gagnant = "Joueur X");
        }

        else if (listeCoche[6]=="Bleu" && listeCoche[7]=="Bleu" && listeCoche[8]=="Bleu"){
            console.log("VICTOIRE JOUEUR O");
            coloriageCase(x=6,y=7,z=8);
            newGame(gagnant = "Joueur O");
        }

        //147
        else if(listeCoche[0]=="Rouge" && listeCoche[3]=="Rouge" && listeCoche[6]=="Rouge"){
            console.log("VICTOIRE JOUEUR X");
            coloriageCase(x=0,y=3,z=6);
            newGame(gagnant = "Joueur X");
        }

        else if (listeCoche[0]=="Bleu" && listeCoche[3]=="Bleu" && listeCoche[6]=="Bleu"){
            console.log("VICTOIRE JOUEUR O");
            coloriageCase(x=0,y=3,z=6);
            newGame(gagnant = "Joueur O");
        }
        //258
        else if(listeCoche[1]=="Rouge" && listeCoche[4]=="Rouge" && listeCoche[7]=="Rouge"){
            console.log("VICTOIRE JOUEUR X");
            coloriageCase(x=1,y=4,z=7);
            newGame(gagnant = "Joueur X");
        }

        else if (listeCoche[1]=="Bleu" && listeCoche[4]=="Bleu" && listeCoche[7]=="Bleu"){
            console.log("VICTOIRE JOUEUR O");
            coloriageCase(x=1,y=4,z=7);
            newGame(gagnant = "Joueur O");
        }
        //369
        else if(listeCoche[2]=="Rouge" && listeCoche[5]=="Rouge" && listeCoche[8]=="Rouge"){
            console.log("VICTOIRE JOUEUR X");
            coloriageCase(x=2,y=5,z=8);
            newGame(gagnant = "Joueur X");
        }

        else if (listeCoche[2]=="Bleu" && listeCoche[5]=="Bleu" && listeCoche[8]=="Bleu"){
            console.log("VICTOIRE JOUEUR O");
            coloriageCase(x=2,y=5,z=8);
            newGame(gagnant = "Joueur O");
        }
        //159
        else if(listeCoche[0]=="Rouge" && listeCoche[4]=="Rouge" && listeCoche[8]=="Rouge"){
            console.log("VICTOIRE JOUEUR X");
            coloriageCase(x=0,y=4,z=8);
            newGame(gagnant = "Joueur X");
        }

        else if (listeCoche[0]=="Bleu" && listeCoche[4]=="Bleu" && listeCoche[8]=="Bleu"){
            console.log("VICTOIRE JOUEUR O");
            coloriageCase(x=0,y=4,z=8);
            newGame(gagnant = "Joueur O");
        }
        //357
        else if(listeCoche[2]=="Rouge" && listeCoche[4]=="Rouge" && listeCoche[6]=="Rouge"){
            console.log("VICTOIRE JOUEUR X");
            coloriageCase(x=2,y=4,z=6);
            newGame(gagnant = "Joueur X");
        }

        else if (listeCoche[2]=="Bleu" && listeCoche[4]=="Bleu" && listeCoche[6]=="Bleu"){
            console.log("VICTOIRE JOUEUR O");
            coloriageCase(x=2,y=4,z=6);
            newGame(gagnant = "Joueur O");
        }

    }
    function coloriageCase(x , y, z){
        let cases = document.getElementsByTagName("div");
        for(let j=0; j<9; j++){
            if (cases[j].id == x || cases[j].id == y || cases[j].id == z ){
                cases[j].style.border = "solid green 3px";
            }
        }
    }

    function newGame(gagnant){
        let joueurActuel = document.getElementById("joueur");
        let image = document.getElementsByTagName("img");
        let cases = document.getElementsByClassName("cases");

        listeCoche=[".",".",".",".",".",".",".",".","."];
        i = -1;

        joueurActuel.innerHTML = "Le gagnant est :" + gagnant;

        setTimeout(() => {
            for(let j=0; j < 9; j++){
            
            image[j].src = "img/blank.png";
            image[j].classList.remove("bleu");
            image[j].classList.remove("rouge");
            cases[j].style.border = "solid 2px";
            }
            
            joueurActuel.innerHTML = "Au tour du joueur O";
        }, 2000);
    }