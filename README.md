# RecipeApp
Это приложение показывает случайные рецепты, полученные с API. Приложение предусматривает работу без интернета, так как имеет локальное хранилище.  
Была использована архитектура MVP (with router) в связи с маленьким размером проекта. Реализация исключительно в коде.

# Оглавление
[Приложение в работе](#workingApp)  
[Особенности](#features)

<a name="workingApp"></a>
## Приложение в работе
![GIF](https://github.com/VladislavGolovachev/RecipeApp/blob/main/RecipeApp.gif)
<img src="https://github.com/VladislavGolovachev/RecipeApp/blob/main/MainScreen.png" alt="drawing" width="310"/>
<img src="https://github.com/VladislavGolovachev/RecipeApp/blob/main/RecipeScreen.png" alt="drawing" width="310"/>
<img src="https://github.com/VladislavGolovachev/RecipeApp/blob/main/WebScreen.png" alt="drawing" width="310"/>

<a name="features"></a>
## Особенности
* UICollectionView с кастомными ячейками,
* UICollectionViewDataSourcePrefetching,
* бесконечная лента (infinite scroll),
* CoreData,
* GCD,
* WebKit,
* паттерн builder для сборки модулей,
* разделение проекта на слои,
* реализация refreshControl у collectionView,
* UIActivityIndicator.
