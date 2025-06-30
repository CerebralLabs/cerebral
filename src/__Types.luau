export type JSONAcceptable = { JSONAcceptable } | { [string]: JSONAcceptable } | number | string | boolean | buffer

export type Attribute<A, B> = typeof(setmetatable({}, {})) & {
	Name: string,
	Value: B,
	__Subscribed: boolean,
	New: (...any) -> A,
	GetSafe: (self: A) -> JSONAcceptable,
	Set: (self: A, ...any) -> (),
} & A

export type Subscribed<A, B> = Attribute<A, B> & {
	Fire: (...any) -> (),
	Connect: (...any) -> (),
	__signal: {
		Connect: (self: any, listener: (JSONAcceptable) -> ()) -> any,
		Fire: (self: any, ...any) -> ()
	},
} & A

export type Profile = {
	playerName: string,
	playerId: number,
	attributes: { [string]: {
		class: Attribute<any, any>,
		subscribed: boolean,
	} }, -- unsure if any is correct here
}

export type Cerebral = {
	Agents: { [string]: Profile },
}

export type AvailableDefaultModules = "boolean" | "string" | "number"

return {}
