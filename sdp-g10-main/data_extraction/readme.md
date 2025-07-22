## Data extraction with AI assistance

**Note: Double check everything after using AI Models.**

### To convert any Mahawer plain text pdf to JSON in different AI Models do the following:
    #### deepsek:
        1- Use the following prompt attached with the pdf:
            {
            "surahID": string,
            "surahName": string,
            "author": string,
            "publication": {
                "publisher": string,
                "year": number,
                "location": string,
                "isbn": string,
                "deposit_number": string
            },
            "mahawer": [
                {
                "id": string, //starts from 1
                "type": string,
                "sequence": string, should be like the type but add أول، ثاني،... besides it,  for مقدمة and  خاتمة do not do this just right them as they are
                "title": string,
                "text": string,
                "startAya": number,
                "endAya": number,
                "isMuqadimah": boolean (optional),
                "isKhatimah": boolean (optional),
                "sections": [
                    {
                    "id": string,
                    "type": string,
                    "sequence": string,
                    "title": string (optional),
                    "text": string,
                    "ayat": [number],
                    "conclusion": string (optional),
                    "subSections": [
                        {
                        "id": string,
                        "type": string,
                        "sequence": string,
                        "text": string,
                        "ayat": [number] (optional),
                        "cases": [
                            {
                            "id": string,
                            "type": string,
                            "sequence": string,
                            "text": string
                            }
                        ] (optional),
                        "conclusion": string (optional)
                        }
                    ] (optional)
                    }
                ]
                }
            ]
            } based on this structure convert the attached pdf into JSON, don't miss, change, nor shorten any sentence        

    #### ChatGPT:
        1- Delete the **unnecessary** pages from the pdf
        2- Use the following prompt attached with the pdf:
            {
            "surahID": string,
            "surahName": string,
            "author": string,
            "publication": {
                "publisher": string,
                "year": number,
                "location": string,
                "isbn": string,
                "deposit_number": string
            },
            "mahawer": [
                {
                "id": string, //starts from 1
                "type": string,
                "sequence": string, should be like the type but add أول، ثاني،... besides it,  for مقدمة and  خاتمة do not do this just right them as they are
                "title": string,
                "text": string,
                "startAya": number,
                "endAya": number,
                "isMuqadimah": boolean (optional),
                "isKhatimah": boolean (optional),
                "sections": [
                    {
                    "id": string,
                    "type": string,
                    "sequence": string,
                    "title": string (optional),
                    "text": string,
                    "ayat": [number],
                    "conclusion": string (optional),
                    "subSections": [
                        {
                        "id": string,
                        "type": string,
                        "sequence": string,
                        "text": string,
                        "ayat": [number] (optional),
                        "cases": [
                            {
                            "id": string,
                            "type": string,
                            "sequence": string,
                            "text": string
                            }
                        ] (optional),
                        "conclusion": string (optional)
                        }
                    ] (optional)
                    }
                ]
                }
            ]
            } based on this structure convert the attached pdf into JSON, don't miss, change, nor shorten any sentence
        3- This will give you the main structure without the sub-section so you need to ask the AI model to proceed with the sub-sections in each mehwar.