import asyncio
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware

from pydantic_models.chat_body import ChatBody
from services.llm_service import LLMService
from services.sort_source_service import SortSourceService
from services.search_service import SearchService

app=FastAPI()#it searches for this word app and then it will create an instance of the FastAPI class and then it will be used to define the routes
#if named other variable rather than app then it gives error

# Add CORS middleware for production deployment
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Health check endpoint
@app.get("/")
def root():
    return {"message": "InquireAI Backend is running!", "status": "healthy"}

# @app.get("/")
# def hello_world():
#     return "Hello World"#whatever we return over here will be the return value for when the user reaches the forward slash route

search_service=SearchService()#we have created an instance of the SearchService class
sort_source_service=SortSourceService()#we have created an instance of the SortSourceService class
llm_service=LLMService()#we have created an instance of the LLMService class


#chat websocket
@app.websocket("/ws/chat")
async def websocket_chat_endpoint(websocket: WebSocket):#accepting the websocket as a parameter
    #firstly acceppt the connection request thatt hey a connection is established we are good to go
    await websocket.accept()#since await not given so convert the whole fxn into an async fxn
    
    try:
        await asyncio.sleep(0.1)
        data=await websocket.receive_json()#receive the data from the websocket
        # print(data)
        #(we get a dictionary fron the websocket and in that dictionary we just look for the query argument so that we get the correct value)
        query=data.get('query')#get the query from the data that we received
        #we can add additional checks that if not query then we will return an error
        # print(query)

        search_results=search_service.web_search(query)
        # print(search_results)
        sorted_results=sort_source_service.sort_sources(query,search_results)
        #as soon as we get the results i will send this data back to our frontend side
        #so after we get the search results and after we are done sorting it ,we will send it back to the user
        # print("hi ",sorted_results," ihj")
        await asyncio.sleep(0.1)
        await websocket.send_json({"type":"search_results","data":sorted_results})
        # print("hi")
        #how do i stream this  data fron this websocket to my client side
        for chunk in llm_service.generate_response(query,sorted_results):
            await asyncio.sleep(0.1)
            await websocket.send_json({"type":"content","data":chunk})

               
    
    except:#similar to catch block 
        print("Unexpected Error Occurred")
    finally:
        await websocket.close()

#chat
#if used query in the parameter of function-->> /chat?query=Who%20is%20Rivaan?-->we will get this partciular string from the query(that's not how u get the body of the request)
#to get the body of the request we will have to create a pydanitc model that will allow us to get the body
@app.post("/chat")
def chat_endpoint(body: ChatBody):
    #search the web and find appropriate sources(step1)
    search_results=search_service.web_search(body.query)
    # print(search_results)


    #sort the sources based on the content(step2)
    #how?->do a similiarity search between the query and search_results:if similarity is high then i want it to rank up
    sorted_results=sort_source_service.sort_sources(body.query,search_results)
    # print(sorted_results)


    #generate the response using an llm model(step3)
    response=llm_service.generate_response(body.query,sorted_results)


    return response


#in our post request when we wanted to get the query from the user,we took it from the body of the request
#but websocket doesn't have any sort of functionality like that